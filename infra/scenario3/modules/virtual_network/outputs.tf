output "private_endpoint_subnet_resource_id" {
  description = "The resource ID of the subnet for the private endpoint"
  value       = var.private_endpoint_subnet_resource_id
}

output "apim_subnet_resource_id" {
  description = "The resource ID of the subnet for the APIM"
  value       = var.apim_subnet_resource_id
}

output "logic_app_subnet_resource_id" {
  description = "The resource ID of the subnet for the Logic App"
  value       = var.logic_app_subnet_resource_id
}

output "function_app_subnet_resource_id" {
  description = "The resource ID of the subnet for the Function App"
  value       = var.function_app_subnet_resource_id
}
