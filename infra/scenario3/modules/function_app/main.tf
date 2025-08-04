module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "~> 0.17.2"

  kind                                           = "functionapp"
  name                                           = module.naming.function_app.name
  location                                       = var.location
  resource_group_name                            = var.resource_group_name
  os_type                                        = "Linux"
  service_plan_resource_id                       = var.service_plan_resource_id
  function_app_uses_fc1                          = false
  tags                                           = var.tags
  app_settings                                   = var.app_settings
  fc1_runtime_name                               = "python"
  fc1_runtime_version                            = "3.12"
  key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  webdeploy_publish_basic_authentication_enabled = false
  https_only                                     = true
  site_config = {
    ip_restriction_default_action          = "Deny"
    application_insights_connection_string = var.application_insights_connection_string
    application_insights_key               = var.application_insights_key
  }
  managed_identities = {
    user_assigned_resource_ids = [var.managed_identity_id]
  }
  virtual_network_subnet_id         = var.vnet_function_subnet_id
  storage_account_name              = var.storage_account_name
  storage_authentication_type       = "UserAssignedIdentity"
  storage_user_assigned_identity_id = var.managed_identity_id
  storage_account_share_name        = var.storage_account_share_name
  public_network_access_enabled     = false
  all_child_resources_inherit_tags  = false
  private_endpoints = {
    primary = {
      subnet_resource_id = var.private_endpoint_subnet_id
    }
  }
  enable_application_insights = false
  # diagnostic_settings = {
  #   logging = {
  #     name                  = "function-logging"
  #     workspace_resource_id = var.log_analytics_workspace_id
  #     log_groups            = ["allLogs", "audit"]
  #     metric_categories     = ["AllMetrics"]
  #   }
  # }
}
