module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "service_bus" {
  source              = "Azure/avm-res-servicebus-namespace/azurerm"
  version             = "0.4.0"
  sku                 = var.sku
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = module.naming.servicebus_namespace.name
  private_endpoints = {
    primary = {
      subnet_resource_id = var.private_endpoint_subnet_id
    }
  }
  diagnostic_settings = {
    logging = {
      name                  = "servicebus-logging"
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs", "audit"]
      metric_categories     = ["AllMetrics"]
    }
  }
  tags     = var.tags
  capacity = var.capacity
  managed_identities = {
    user_assigned_resource_ids = [var.managed_identity_id]
  }
  public_network_access_enabled = false
  network_rule_config = {
    #default_action           = "Deny"
    trusted_services_allowed = true
  }
  role_assignments = {
    managed_identity_servicebus_owner = {
      role_definition_id_or_name = "Azure Service Bus Data Owner"
      principal_id               = var.managed_identity_principal_id
      principal_type             = "ServicePrincipal"
    }
  }
  private_endpoints_manage_dns_zone_group = false
}
