module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "logic_app" {
  source                   = "Azure/avm-res-web-site/azurerm"
  version                  = "0.18.0"
  name                     = module.naming.logic_app_workflow.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  kind                     = "logicapp"
  os_type                  = "Linux"
  service_plan_resource_id = var.service_plan_resource_id
  tags                     = var.tags
  app_settings             = var.app_settings
  # diagnostic_settings = {
  #   logging = {
  #     name                  = "logging"
  #     workspace_resource_id = var.log_analytics_workspace_id
  #     log_groups            = ["allLogs", "audit"]
  #     metric_categories     = ["AllMetrics"]
  #   }
  # }
  private_endpoints = {
    primary = {
      subnet_resource_id = var.private_endpoint_subnet_id
    }
  }
  virtual_network_subnet_id       = var.vnet_logic_app_subnet_id
  key_vault_reference_identity_id = var.managed_identity_id
  managed_identities = {
    user_assigned_resource_ids = [var.managed_identity_id]
  }
  application_insights = {
    workspace_resource_id = var.log_analytics_workspace_id
  }
  site_config = {
    ip_restriction_default_action = "Deny"
  }
  storage_account_name             = var.storage_account_name
  storage_account_access_key       = var.storage_account_access_key
  storage_account_share_name       = var.storage_account_share_name
  public_network_access_enabled    = false
  all_child_resources_inherit_tags = false
}
