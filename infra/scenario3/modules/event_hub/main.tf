module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "eventhub_namespace" {
  source              = "Azure/avm-res-eventhub-namespace/azurerm"
  version             = "0.1.0"
  name                = module.naming.eventhub_namespace.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity
  tags                = var.tags
  managed_identities = {
    user_assigned_resource_ids = [var.managed_identity_id]
  }
  private_endpoints = {
    primary = {
      subnet_resource_id = var.private_endpoint_subnet_id
      subresource_name   = "namespace"
    }
  }
  diagnostic_settings = {
    logging = {
      name                  = "eventhub-logging"
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs", "audit"]
      metric_categories     = ["AllMetrics"]
    }
  }
  network_rulesets = {
    default_action                 = "Deny"
    trusted_service_access_enabled = true
    public_network_access_enabled  = false
  }
}

