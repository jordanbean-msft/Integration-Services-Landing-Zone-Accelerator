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

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace."
  type        = string
}

variable "managed_identity_id" {
  description = "The ID of the user-assigned managed identity."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity."
  type        = string
}

variable "key_values" {
  description = "Key-value pairs for the App Configuration store."
  type = map(object({
    key          = string
    value        = string
    content_type = optional(string, null)
    label        = optional(string, null)
    tags         = optional(map(string), null)
  }))
}

variable "private_endpoint_subnet_id" {
  description = "The subnet ID for the private endpoint."
  type        = string
}

variable "sku" {
  description = "The SKU for the App Configuration store."
  type        = string
  default     = "Standard"
}


