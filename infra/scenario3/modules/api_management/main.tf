# ------------------------------------------------------------------------------------------------------
# Deploy API Management
# ------------------------------------------------------------------------------------------------------
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

# data "azapi_resource" "resource_group" {
#   type = "Microsoft.Resources/resourceGroups@2021-04-01"
#   name = var.resource_group_name
# }


# resource "azurerm_api_management" "api_management" {
#   name                = module.naming.api_management.name
#   location            = var.location
#   tags                = var.tags
#   resource_group_name = var.resource_group_name
#   publisher_email     = var.publisher_email
#   publisher_name      = var.publisher_name
#   sku_name            = "${var.sku_name}_${var.sku_capacity}"
#   identity {
#     type         = "UserAssigned"
#     identity_ids = [var.user_assigned_identity_id]
#   }
#   virtual_network_type = "Internal"
#   virtual_network_configuration {
#     subnet_id = var.api_management_subnet_id
#   }
#   zones                         = var.zones
#   public_network_access_enabled = true // temporary because you cannot disable public network access on a new APIM instance, it will be updated later to be disabled

#   lifecycle {
#     ignore_changes = [
#       public_network_access_enabled
#     ]
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "apim_logging" {
#   name                       = "apim-logging"
#   target_resource_id         = azurerm_api_management.api_management.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   enabled_log {
#     category_group = "allLogs"
#   }

#   enabled_metric {
#     category = "AllMetrics"
#   }
# }

# module "private_endpoint" {
#   source  = "Azure/avm-res-network-privateendpoint/azurerm"
#   version = "0.2.0"

#   name                           = module.naming.private_endpoint.name_unique
#   location                       = var.location
#   resource_group_name            = var.resource_group_name
#   network_interface_name         = "nic-apim-${module.naming.private_endpoint.name_unique}"
#   private_connection_resource_id = azurerm_api_management.api_management.id
#   subnet_resource_id             = var.private_endpoint_subnet_id
#   subresource_names              = ["Gateway"]
# }

# resource "azapi_update_resource" "update_api_management" {
#   type        = "Microsoft.ApiManagement/service@2024-06-01-preview"
#   resource_id = azurerm_api_management.api_management.id
#   depends_on  = [module.private_endpoint]
#   body = {
#     properties = {
#       publicNetworkAccess = "Disabled"
#     }
#   }
# }

module "api_management" {
  source              = "Azure/avm-res-apimanagement-service/azurerm"
  version             = "0.0.4"
  name                = module.naming.api_management.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = "${var.sku_name}_${var.sku_capacity}"
  tags                = var.tags
  diagnostic_settings = {
    default = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }
  managed_identities = {
    user_assigned_identity_id = [var.user_assigned_identity_id]
  }
  public_network_access_enabled = true
  virtual_network_subnet_id     = var.api_management_subnet_id
  virtual_network_type          = "Internal"
  zones                         = (var.sku_name == "Premium") ? var.zones : null
}

# resource "azapi_update_resource" "update_api_management" {
#   type        = "Microsoft.ApiManagement/service@2024-06-01-preview"
#   resource_id = module.api_management.resource_id
#   body = {
#     properties = {
#       publicNetworkAccess = "Disabled"
#     }
#   }
# }
