module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "avm-res-network-networksecuritygroup" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.0"

  name                = module.naming.network_security_group.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  security_rules      = length(var.security_rules) > 0 ? var.security_rules : null
}
