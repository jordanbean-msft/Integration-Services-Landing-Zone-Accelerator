output "name" {
  description = "Name of the app service plan"
  value       = module.app_service_plan.name
}

output "resource_id" {
  description = "Resource id of the app service plan"
  value       = module.app_service_plan.resource_id
}

output "resource" {
  description = "The full output of the resource."
  value       = module.app_service_plan.resource
}
