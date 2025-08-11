module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "avm-res-appconfiguration-configurationstore" {
  source                     = "Azure/avm-res-appconfiguration-configurationstore/azure"
  version                    = "0.5.0"
  name                       = module.naming.app_configuration.name
  location                   = var.location
  resource_group_resource_id = data.azurerm_resource_group.rg.id
  tags                       = var.tags
  sku                        = var.sku
  diagnostic_settings = {
    logging = {
      name                  = "logging"
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs", "audit"]
      metric_categories     = ["AllMetrics"]
    }
  }
  managed_identities = {
    user_assigned_resource_ids = [var.managed_identity_id]
  }
  key_values = var.key_values
  private_endpoints = {
    primary = {
      subnet_resource_id = var.private_endpoint_subnet_id
      subresource_name   = "namespace"
    }
  }
  private_endpoints_manage_dns_zone_group = false
  public_network_access_enabled           = false
  role_assignments = {
    managed_identity_app_configuration_data_reader = {
      role_definition_id_or_name = "App Configuration Data Owner"
      principal_id               = var.managed_identity_principal_id
      principal_type             = "ServicePrincipal"
    }
  }
  purge_protection_enabled = false
}
