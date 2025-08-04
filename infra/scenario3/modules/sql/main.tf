module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "azure_sql" {
  source              = "Azure/avm-res-sql-server/azurerm"
  version             = "0.1.5"
  name                = module.naming.sql_server.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  server_version      = var.server_version
  diagnostic_settings = {
    logging = {
      name                  = "logging"
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs", "audit"]
      metric_categories     = ["AllMetrics"]
    }
  }
  private_endpoints = {
    primary = {
      subnet_resource_id = var.private_endpoint_subnet_id
    }
  }
  managed_identities = {
    user_assigned_resource_ids = [var.managed_identity_id]
  }
  primary_user_assigned_identity_id = var.managed_identity_id
  public_network_access_enabled     = false
}
