
data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.1"

  name                           = module.naming.key_vault.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  sku_name                       = "standard"
  tags                           = var.tags
  public_network_access_enabled  = false
  legacy_access_policies_enabled = false
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
  role_assignments = merge(
    { for idx, oid in var.access_policy_object_ids : "user_${idx}" => {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = oid
      }
    },
    {
      officer = {
        role_definition_id_or_name = "Key Vault Secrets Officer"
        principal_id               = var.principal_id
      }
    }
  )
  diagnostic_settings = {
    logging = {
      name                  = "key-vault-logging"
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  private_endpoints = {
    primary = {
      subnet_resource_id = var.subnet_id
    }
  }
}
