module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
  suffix  = [var.name_suffix]
}

module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "~> 0.7.0"

  name                   = module.naming.app_service_plan.name
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = var.os_type
  sku_name               = var.sku_name
  tags                   = var.tags
  zone_balancing_enabled = var.zone_balancing_enabled
  worker_count           = var.worker_count
}
