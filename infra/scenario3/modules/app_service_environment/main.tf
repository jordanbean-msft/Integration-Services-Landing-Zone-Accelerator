module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "app_service_environment" {
  source              = "Azure/avm-res-web-hostingenvironment/azurerm"
  version             = "0.4.0"
  resource_group_name = var.resource_group_name
  name                = module.naming.app_service_environment.name
  diagnostic_settings = {
    logging = {
      name                  = "app-service-env-logging"
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs", "audit"]
      metric_categories     = ["AllMetrics"]
    }
  }
  managed_identities = {
    user_assigned_resource_ids = [var.managed_identity_id]
  }
  subnet_id      = var.subnet_resource_id
  zone_redundant = var.zone_balancing_enabled
}
