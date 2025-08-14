module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azapi_resource" "api_center" {
  type      = "Microsoft.ApiCenter/services@2024-06-01-preview"
  name      = "apic-${var.name_suffix}"
  parent_id = data.azurerm_resource_group.rg.id
  location  = var.location
  identity {
    type = "UserAssigned"
    identity_ids = [
      var.managed_identity_id
    ]
  }
  body = {
    properties = {
    }
  }
  tags = var.tags
}
