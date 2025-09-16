output "api_management_name" {
  value = module.api_management.name
}

output "api_management_id" {
  value = module.api_management.resource_id
}

output "api_management_gateway_url" {
  value = module.api_management.gateway_regional_url
}
