output "network_security_group_id" {
  description = "The resource ID of the Network Security Group."
  value       = module.avm-res-network-networksecuritygroup.resource_id
}

output "network_security_group_name" {
  description = "The name of the Network Security Group."
  value       = module.avm-res-network-networksecuritygroup.name
}
