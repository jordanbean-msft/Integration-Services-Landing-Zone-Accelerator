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

variable "os_type" {
  description = "The operating system type. Possible values: Linux, Windows, WindowsContainer."
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the App Service Plan. Defaults to P1v2."
  type        = string
  default     = "P1v2"
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "zone_balancing_enabled" {
  description = "Should zone balancing be enabled for this App Service Plan?"
  type        = bool
  default     = true
}

variable "worker_count" {
  description = "The number of workers to allocate for this App Service Plan."
  type        = number
}

variable "app_service_environment_id" {
  description = "The ID of the App Service Environment to associate with this App Service Plan."
  type        = string
}
