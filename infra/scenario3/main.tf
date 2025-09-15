locals {
  tags              = { azd-env-name : var.environment_name }
  sha               = base64encode(sha256("${var.location}${data.azurerm_client_config.current.subscription_id}${var.resource_group_name}"))
  name_suffix       = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  function_app_name = "func-${local.name_suffix}"
  logic_app_name    = "logic-${local.name_suffix}"
}

data "azurerm_subnet" "private_endpoint_subnet" {
  name                 = var.network.private_endpoint_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}

data "azurerm_subnet" "apim_subnet" {
  name                 = var.network.apim_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}

data "azurerm_subnet" "app_service_environment_subnet" {
  name                 = var.network.app_service_environment_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}

# ------------------------------------------------------------------------------------------------------
# Deploy Log Analytics Workspace
# ------------------------------------------------------------------------------------------------------

module "log_analytics_workspace" {
  source              = "./modules/log_analytics"
  name_suffix         = local.name_suffix
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy Application Insights
# ------------------------------------------------------------------------------------------------------

module "application_insights" {
  source                = "./modules/app_insights"
  name_suffix           = local.name_suffix
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
  tags                  = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy Managed Identity
# ------------------------------------------------------------------------------------------------------

module "managed_identity" {
  source              = "./modules/managed_identity"
  name_suffix         = local.name_suffix
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy Storage Accounts
# ------------------------------------------------------------------------------------------------------

module "logic_app_storage_account" {
  source                              = "./modules/storage_account"
  name_suffix                         = "logic${local.name_suffix}"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  log_analytics_workspace_resource_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
  private_endpoint_subnet_resource_id = module.virtual_network.private_endpoint_subnet_resource_id
  user_assigned_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  account_tier                        = var.logic_app.storage_account_account_tier
  account_replication_type            = var.logic_app.storage_account_account_replication_type
  file_share_name                     = local.logic_app_name
  file_share_quota                    = var.logic_app.storage_account_file_share_quota
}

module "function_app_storage_account" {
  source                              = "./modules/storage_account"
  name_suffix                         = "func${local.name_suffix}"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  log_analytics_workspace_resource_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
  private_endpoint_subnet_resource_id = module.virtual_network.private_endpoint_subnet_resource_id
  user_assigned_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  account_tier                        = var.function_app.storage_account_account_tier
  account_replication_type            = var.function_app.storage_account_account_replication_type
  file_share_name                     = local.function_app_name
  file_share_quota                    = var.function_app.storage_account_file_share_quota
}

module "file_storage_account" {
  source                              = "./modules/storage_account"
  name_suffix                         = "file${local.name_suffix}"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  log_analytics_workspace_resource_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
  private_endpoint_subnet_resource_id = module.virtual_network.private_endpoint_subnet_resource_id
  user_assigned_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  account_tier                        = var.file_storage_storage_account.account_tier
  account_replication_type            = var.file_storage_storage_account.account_replication_type
}

# ------------------------------------------------------------------------------------------------------
# Deploy Virtual Network
# ------------------------------------------------------------------------------------------------------

module "virtual_network" {
  source                                     = "./modules/virtual_network"
  private_endpoint_subnet_resource_id        = data.azurerm_subnet.private_endpoint_subnet.id
  apim_subnet_resource_id                    = data.azurerm_subnet.apim_subnet.id
  app_service_environment_subnet_resource_id = data.azurerm_subnet.app_service_environment_subnet.id
}

# ------------------------------------------------------------------------------------------------------
# Deploy App Service Environment
# ------------------------------------------------------------------------------------------------------

module "app_service_environment" {
  source                     = "./modules/app_service_environment"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  name_suffix                = local.name_suffix
  tags                       = local.tags
  log_analytics_workspace_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
  managed_identity_id        = module.managed_identity.user_assigned_identity_id
  subnet_resource_id         = module.virtual_network.app_service_environment_subnet_resource_id
  zone_balancing_enabled     = var.zone_redundancy_enabled
}

# ------------------------------------------------------------------------------------------------------
# Deploy App Service Plans
# ------------------------------------------------------------------------------------------------------
module "logic_app_app_service_plan" {
  source                     = "./modules/app_service_plan"
  name_suffix                = "logic-${local.name_suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  os_type                    = "Windows"
  sku_name                   = var.logic_app.sku_name
  tags                       = local.tags
  zone_balancing_enabled     = var.zone_redundancy_enabled
  worker_count               = var.logic_app.worker_count
  app_service_environment_id = module.app_service_environment.id
}

module "function_app_app_service_plan" {
  source                     = "./modules/app_service_plan"
  name_suffix                = "function-${local.name_suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  os_type                    = "Windows"
  sku_name                   = var.function_app.sku_name
  tags                       = local.tags
  zone_balancing_enabled     = var.zone_redundancy_enabled
  worker_count               = var.function_app.worker_count
  app_service_environment_id = module.app_service_environment.id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Key Vault
# ------------------------------------------------------------------------------------------------------

module "key_vault" {
  source                     = "./modules/key_vault"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tags                       = local.tags
  name_suffix                = local.name_suffix
  principal_id               = var.principal_id
  access_policy_object_ids   = []
  secrets                    = []
  subnet_id                  = module.virtual_network.private_endpoint_subnet_resource_id
  log_analytics_workspace_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Functions
# ------------------------------------------------------------------------------------------------------

module "function_app" {
  source                        = "./modules/function_app"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  name_suffix                   = local.name_suffix
  service_plan_resource_id      = module.function_app_app_service_plan.resource_id
  tags                          = merge(local.tags, { "azd-service-name" = "function-app" })
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  managed_identity_id           = module.managed_identity.user_assigned_identity_id
  storage_account_name          = module.function_app_storage_account.storage_account_name
  storage_account_share_name    = local.function_app_name
  storage_account_access_key    = module.function_app_storage_account.storage_account_access_key
  app_settings = {
    "AzureWebJobsStorage"                      = module.function_app_storage_account.storage_account_connection_string
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = module.function_app_storage_account.storage_account_connection_string
    "WEBSITE_CONTENTSHARE"                     = local.function_app_name
    "WEBSITE_DNS_SERVER"                       = var.function_app.website_dns_server
    "WEBSITE_CONTENTOVERVNET"                  = "1"
    "FUNCTIONS_WORKER_RUNTIME"                 = "java"
  }
  log_analytics_workspace_id             = module.log_analytics_workspace.log_analytics_workspace_resource_id
  application_insights_connection_string = module.application_insights.application_insights_connection_string
  application_insights_key               = module.application_insights.application_insights_key
  key_vault_reference_identity_id        = module.managed_identity.user_assigned_identity_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Logic App
# ------------------------------------------------------------------------------------------------------

module "logic_app" {
  source                        = "./modules/logic_app"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  name_suffix                   = local.name_suffix
  service_plan_resource_id      = module.logic_app_app_service_plan.resource_id
  tags                          = merge(local.tags, { "azd-service-name" = "logic-app" })
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  managed_identity_id           = module.managed_identity.user_assigned_identity_id
  storage_account_name          = module.logic_app_storage_account.storage_account_name
  storage_account_access_key    = module.logic_app_storage_account.storage_account_access_key
  storage_account_share_name    = local.logic_app_name
  app_settings = {
    "WEBSITE_DNS_SERVER" : var.logic_app.website_dns_server
    "APPLICATIONINSIGHTS_CONNECTIONSTRING" : module.application_insights.application_insights_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" : module.application_insights.application_insights_key
    "ApplicationInsightsAgent_EXTENSION_VERSION" : "~2"
    "FUNCTIONS_WORKER_RUNTIME" : "dotnet"
  }
  log_analytics_workspace_id             = module.log_analytics_workspace.log_analytics_workspace_resource_id
  application_insights_connection_string = module.application_insights.application_insights_connection_string
  application_insights_key               = module.application_insights.application_insights_key
}

# ------------------------------------------------------------------------------------------------------
# Deploy Network Security Groups for each subnet
# ------------------------------------------------------------------------------------------------------

module "nsg_private_endpoint" {
  source              = "./modules/network_security_group"
  name_suffix         = "pe-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = {}
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "private_endpoint" {
  subnet_id                 = module.virtual_network.private_endpoint_subnet_resource_id
  network_security_group_id = module.nsg_private_endpoint.network_security_group_id
}

module "nsg_apim" {
  source              = "./modules/network_security_group"
  name_suffix         = "apim-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  security_rules = {
    rule_100_inbound = {
      name                       = "AllowManagementEndpointForAzurePortalInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "ApiManagement"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "3443"
    }
    rule_110_inbound = {
      name                       = "AllowExternalRedisCacheInbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "6380"
    }
    rule_120_inbound = {
      name                       = "AllowInternalRedisCacheInbound"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "6381-6383"
    }
    rule_130_inbound = {
      name                       = "AllowSyncCountersForRateLimitingInbound"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "4290"
    }
    rule_140_inbound = {
      name                       = "AllowAzureInfrastructureLoadBalancerInbound"
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "AzureLoadBalancer"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "6390"
    }
    rule_150_inbound = {
      name                       = "AllowMonitoringOfIndividualMachineHealthInbound"
      priority                   = 150
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "AzureLoadBalancer"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "6391"
    }
    rule_100_outbound = {
      name                       = "AllowValidationAndMgmtOfMicrosoftAndCustomerCertificatesOutbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "Internet"
      destination_port_range     = "80"
    }
    rule_110_outbound = {
      name                       = "AllowDependencyOnAzureStorageOutbound"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "Storage"
      destination_port_range     = "443"
    }
    rule_120_outbound = {
      name                       = "AllowMicrosoftEntraGraphAndKeyVaultOutbound"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "AzureActiveDirectory"
      destination_port_range     = "443"
    }
    rule_130_outbound = {
      name                       = "AllowManagedConnectorsOutbound"
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "AzureConnectors"
      destination_port_range     = "443"
    }
    rule_140_outbound = {
      name                       = "AllowAzureSQLOutbound"
      priority                   = 140
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "Sql"
      destination_port_range     = "1433"
    }
    rule_150_outbound = {
      name                       = "AllowKeyVaultOutbound"
      priority                   = 150
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "AzureKeyVault"
      destination_port_range     = "443"
    }
    rule_160_outbound = {
      name                       = "AllowEventHubAndMonitorOutbound"
      priority                   = 160
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "EventHub"
      destination_port_ranges    = ["5671", "5672", "443"]
    }
    rule_170_outbound = {
      name                       = "AllowAzureFileShareForGitOutbound"
      priority                   = 170
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "Storage"
      destination_port_range     = "445"
    }
    rule_180_outbound = {
      name                       = "AllowPublishDiagnosticsAndAppInsightsOutbound"
      priority                   = 180
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "AzureMonitor"
      destination_port_ranges    = ["1886", "443"]
    }
    rule_190_outbound = {
      name                       = "AllowExternalAzureCacheOutbound"
      priority                   = 190
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "6380"
    }
    rule_200_outbound = {
      name                       = "AllowInternalAzureCacheOutbound"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "6381-6383"
    }
    rule_220_outbound = {
      name                       = "AllowSyncCountersOutbound"
      priority                   = 220
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "4290"
    }
    rule_230_outbound = {
      name                       = "AllowDnsOutbound"
      priority                   = 230
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "53"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "apim" {
  subnet_id                 = module.virtual_network.apim_subnet_resource_id
  network_security_group_id = module.nsg_apim.network_security_group_id
}

module "nsg_app_service_environment" {
  source              = "./modules/network_security_group"
  name_suffix         = "app-service-environment-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "app_service_environment" {
  subnet_id                 = module.virtual_network.app_service_environment_subnet_resource_id
  network_security_group_id = module.nsg_app_service_environment.network_security_group_id
}

module "nsg_logic_app" {
  source              = "./modules/network_security_group"
  name_suffix         = "logic-app-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

module "nsg_function_app" {
  source              = "./modules/network_security_group"
  name_suffix         = "function-app-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy API Management
# ------------------------------------------------------------------------------------------------------

module "api_management" {
  source                                   = "./modules/api_management"
  name_suffix                              = local.name_suffix
  location                                 = var.location
  resource_group_name                      = var.resource_group_name
  tags                                     = local.tags
  api_management_subnet_id                 = module.virtual_network.apim_subnet_resource_id
  application_insights_id                  = module.application_insights.application_insights_id
  application_insights_instrumentation_key = module.application_insights.application_insights_key
  log_analytics_workspace_id               = module.log_analytics_workspace.log_analytics_workspace_resource_id
  key_vault_id                             = module.key_vault.key_vault_id
  private_endpoint_subnet_id               = module.virtual_network.private_endpoint_subnet_resource_id
  publisher_email                          = var.apim.publisher_email
  publisher_name                           = var.apim.publisher_name
  subscription_id                          = data.azurerm_client_config.current.subscription_id
  sku_name                                 = var.apim.sku_name
  sku_capacity                             = var.apim.sku_capacity
  tenant_id                                = data.azurerm_client_config.current.tenant_id
  user_assigned_identity_id                = module.managed_identity.user_assigned_identity_id
  user_assigned_identity_client_id         = module.managed_identity.user_assigned_identity_client_id
  user_assigned_identity_principal_id      = module.managed_identity.user_assigned_identity_principal_id
  zones                                    = var.apim.zones
}

# ------------------------------------------------------------------------------------------------------
# Service Bus
# ------------------------------------------------------------------------------------------------------

module "service_bus" {
  source                        = "./modules/service_bus"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  name_suffix                   = local.name_suffix
  tags                          = local.tags
  sku                           = var.service_bus.sku_name
  capacity                      = var.service_bus.sku_capacity
  private_endpoint_subnet_id    = module.virtual_network.private_endpoint_subnet_resource_id
  managed_identity_id           = module.managed_identity.user_assigned_identity_id
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  log_analytics_workspace_id    = module.log_analytics_workspace.log_analytics_workspace_resource_id
}

# ------------------------------------------------------------------------------------------------------
# App Configuration
# ------------------------------------------------------------------------------------------------------

module "app_configuration" {
  source                        = "./modules/app_configuration"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  name_suffix                   = "${local.name_suffix}1"
  tags                          = local.tags
  sku                           = var.app_configuration.sku
  private_endpoint_subnet_id    = module.virtual_network.private_endpoint_subnet_resource_id
  managed_identity_id           = module.managed_identity.user_assigned_identity_id
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  log_analytics_workspace_id    = module.log_analytics_workspace.log_analytics_workspace_resource_id
  key_values                    = {}
}

# ------------------------------------------------------------------------------------------------------
# API Center
# ------------------------------------------------------------------------------------------------------

module "api_center" {
  source                        = "./modules/api_center"
  location                      = var.api_center.location
  resource_group_name           = var.resource_group_name
  name_suffix                   = local.name_suffix
  tags                          = local.tags
  managed_identity_id           = module.managed_identity.user_assigned_identity_id
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  log_analytics_workspace_id    = module.log_analytics_workspace.log_analytics_workspace_resource_id
}
