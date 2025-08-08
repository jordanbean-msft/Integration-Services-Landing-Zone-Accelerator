variable "location" {
  description = "The Azure region to deploy the App Service Plan."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "name_suffix" {
  description = "Suffix to append to the App Service Plan name for uniqueness."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "zone_balancing_enabled" {
  description = "Should zone balancing be enabled for this App Service Plan?"
  type        = bool
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace."
  type        = string
}

variable "managed_identity_id" {
  description = "The ID of the user-assigned managed identity."
  type        = string
}

variable "subnet_resource_id" {
  description = "The resource ID of the subnet."
  type        = string
}
