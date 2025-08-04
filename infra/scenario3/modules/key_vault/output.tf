output "azure_key_vault_endpoint" {
  value     = module.key_vault.uri
  sensitive = false
}

output "key_vault_id" {
  value     = module.key_vault.resource_id
  sensitive = false
}

output "key_vault_name" {
  value     = module.key_vault.name
  sensitive = false
}
