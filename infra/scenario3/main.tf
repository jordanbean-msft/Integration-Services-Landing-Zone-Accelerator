locals {
  tags              = { azd-env-name : var.environment_name }
  sha               = base64encode(sha256("${var.location}${data.azurerm_client_config.current.subscription_id}${var.resource_group_name}"))
  resource_token    = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  function_app_name = "function-${local.resource_token}"
  logic_app_name    = "logic-${local.resource_token}"
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

data "azurerm_subnet" "logic_app_subnet" {
  name                 = var.network.logic_app_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}

data "azurerm_subnet" "function_app_subnet" {
  name                 = var.network.function_app_subnet_name
  virtual_network_name = var.network.virtual_network_name
  resource_group_name  = var.network.virtual_network_resource_group_name
}

# ------------------------------------------------------------------------------------------------------
# Deploy Log Analytics Workspace
# ------------------------------------------------------------------------------------------------------

module "log_analytics_workspace" {
  source              = "./modules/log_analytics"
  name_suffix         = local.resource_token
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy Application Insights
# ------------------------------------------------------------------------------------------------------

module "application_insights" {
  source                = "./modules/app_insights"
  name_suffix           = local.resource_token
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
  name_suffix         = local.resource_token
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Deploy Storage Accounts
# ------------------------------------------------------------------------------------------------------

module "logic_app_storage_account" {
  source                              = "./modules/storage_account"
  name_suffix                         = "logic${local.resource_token}"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  log_analytics_workspace_resource_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
  private_endpoint_subnet_resource_id = module.virtual_network.private_endpoint_subnet_resource_id
  user_assigned_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  account_tier                        = var.logic_app.storage_account_account_tier
  account_replication_type            = var.logic_app.storage_account_account_replication_type
  file_share_name                     = "logic${local.resource_token}"
  file_share_quota                    = var.logic_app.storage_account_file_share_quota
}

module "function_app_storage_account" {
  source                              = "./modules/storage_account"
  name_suffix                         = "func${local.resource_token}"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  log_analytics_workspace_resource_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
  private_endpoint_subnet_resource_id = module.virtual_network.private_endpoint_subnet_resource_id
  user_assigned_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  account_tier                        = var.function_app.storage_account_account_tier
  account_replication_type            = var.function_app.storage_account_account_replication_type
}

module "file_storage_account" {
  source                              = "./modules/storage_account"
  name_suffix                         = "file${local.resource_token}"
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
  source                              = "./modules/virtual_network"
  private_endpoint_subnet_resource_id = data.azurerm_subnet.private_endpoint_subnet.id
  apim_subnet_resource_id             = data.azurerm_subnet.apim_subnet.id
  logic_app_subnet_resource_id        = data.azurerm_subnet.logic_app_subnet.id
  function_app_subnet_resource_id     = data.azurerm_subnet.function_app_subnet.id
}

# ------------------------------------------------------------------------------------------------------
# Deploy App Service Plans
# ------------------------------------------------------------------------------------------------------
module "logic_app_app_service_plan" {
  source                 = "./modules/app_service_plan"
  name_suffix            = "logic-${local.resource_token}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = "Linux"
  sku_name               = var.logic_app.sku_name
  tags                   = local.tags
  zone_balancing_enabled = var.zone_redundancy_enabled
  worker_count           = var.logic_app.worker_count
}

module "function_app_app_service_plan" {
  source                 = "./modules/app_service_plan"
  name_suffix            = "function-${local.resource_token}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = "Linux"
  sku_name               = var.function_app.sku_name
  tags                   = local.tags
  zone_balancing_enabled = var.zone_redundancy_enabled
  worker_count           = var.function_app.worker_count
}

# ------------------------------------------------------------------------------------------------------
# Deploy Key Vault
# ------------------------------------------------------------------------------------------------------

module "key_vault" {
  source                     = "./modules/key_vault"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tags                       = local.tags
  name_suffix                = local.resource_token
  principal_id               = var.principal_id
  access_policy_object_ids   = []
  secrets                    = []
  subnet_id                  = data.azurerm_subnet.private_endpoint_subnet.id
  log_analytics_workspace_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Functions
# ------------------------------------------------------------------------------------------------------

module "function_app" {
  source                         = "./modules/function_app"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  name_suffix                    = local.function_app_name
  service_plan_resource_id       = module.function_app_app_service_plan.resource_id
  tags                           = merge(local.tags, { "azd-service-name" = "function-app" })
  private_endpoint_subnet_id     = data.azurerm_subnet.private_endpoint_subnet.id
  vnet_function_subnet_id        = data.azurerm_subnet.function_app_subnet.id
  managed_identity_principal_id  = module.managed_identity.user_assigned_identity_principal_id
  managed_identity_id            = module.managed_identity.user_assigned_identity_id
  storage_account_name           = module.function_app_storage_account.storage_account_name
  storage_account_container_name = local.function_app_name
  app_settings                   = {}
  log_analytics_workspace_id     = module.log_analytics_workspace.log_analytics_workspace_resource_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Logic App
# ------------------------------------------------------------------------------------------------------

module "logic_app" {
  source                        = "./modules/logic_app"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  name_suffix                   = local.logic_app_name
  service_plan_resource_id      = module.logic_app_app_service_plan.resource_id
  tags                          = merge(local.tags, { "azd-service-name" = "logic-app" })
  private_endpoint_subnet_id    = data.azurerm_subnet.private_endpoint_subnet.id
  vnet_logic_app_subnet_id      = data.azurerm_subnet.logic_app_subnet.id
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  managed_identity_id           = module.managed_identity.user_assigned_identity_id
  storage_account_name          = module.logic_app_storage_account.storage_account_name
  storage_account_access_key    = module.logic_app_storage_account.storage_account_access_key
  storage_account_share_name    = local.logic_app_name
  app_settings = {
    "WEBSITE_CONTENTOVERVNET" : 1
  }
  log_analytics_workspace_id = module.log_analytics_workspace.log_analytics_workspace_resource_id
}


# ------------------------------------------------------------------------------------------------------
# Deploy Network Security Groups for each subnet
# ------------------------------------------------------------------------------------------------------

module "nsg_private_endpoint" {
  source              = "./modules/network_security_group"
  name_suffix         = "pe-${local.resource_token}"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = {}
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "private_endpoint" {
  subnet_id                 = data.azurerm_subnet.private_endpoint_subnet.id
  network_security_group_id = module.nsg_private_endpoint.network_security_group_id
}

module "nsg_apim" {
  source              = "./modules/network_security_group"
  name_suffix         = "apim-${local.resource_token}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "apim" {
  subnet_id                 = data.azurerm_subnet.apim_subnet.id
  network_security_group_id = module.nsg_apim.network_security_group_id
}

module "nsg_logic_app" {
  source              = "./modules/network_security_group"
  name_suffix         = "logic-app-${local.resource_token}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "logic_app" {
  subnet_id                 = data.azurerm_subnet.logic_app_subnet.id
  network_security_group_id = module.nsg_logic_app.network_security_group_id
}

module "nsg_function_app" {
  source              = "./modules/network_security_group"
  name_suffix         = "function-app-${local.resource_token}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "function_app" {
  subnet_id                 = data.azurerm_subnet.function_app_subnet.id
  network_security_group_id = module.nsg_function_app.network_security_group_id
}
