output "private_endpoint_subnet_resource_id" {
  description = "The resource ID of the subnet for the private endpoint"
  value       = var.private_endpoint_subnet_resource_id
}

output "apim_subnet_resource_id" {
  description = "The resource ID of the subnet for the APIM"
  value       = var.apim_subnet_resource_id
}

output "app_service_environment_subnet_resource_id" {
  description = "The resource ID of the subnet for the App Service Environment"
  value       = var.app_service_environment_subnet_resource_id
}
