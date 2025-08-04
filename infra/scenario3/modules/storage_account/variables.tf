variable "name_suffix" {
  description = "Suffix for the name of the resources"
  type        = string
}

variable "location" {
  description = "The Azure location to deploy the resources"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group where resources will be created"
  type        = string
}

variable "user_assigned_identity_principal_id" {
  description = "The principal ID of the user-assigned identity to assign roles to"
  type        = string
}

variable "private_endpoint_subnet_resource_id" {
  description = "The resource ID of the subnet where the private endpoint will be created"
  type        = string
}

variable "log_analytics_workspace_resource_id" {
  description = "The ID of the Log Analytics Workspace to link with the Storage Account"
  type        = string
}

variable "account_tier" {
  description = "The SKU tier for the Storage Account"
  type        = string
}

variable "account_replication_type" {
  description = "The replication type for the Storage Account"
  type        = string
}

variable "file_share_name" {
  description = "The name of the file share to create in the Storage Account"
  type        = string
  nullable    = true
  default     = null
}

variable "file_share_quota" {
  description = "The quota for the file share in GB"
  type        = number
  nullable    = true
  default     = null
}
