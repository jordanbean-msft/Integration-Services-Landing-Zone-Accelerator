
module "private_endpoint" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "0.2.0"

  name                           = var.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_resource_id             = var.subnet_id
  private_connection_resource_id = var.private_connection_resource_id
  tags                           = var.tags
  subresource_names              = var.subresource_names
  request_message                = var.request_message
  is_manual_connection           = var.is_manual_connection
}
