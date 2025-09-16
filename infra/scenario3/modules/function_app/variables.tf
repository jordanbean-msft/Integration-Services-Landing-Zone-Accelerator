variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "name_suffix" {
  description = "A suffix to append to the resource names for uniqueness."
  type        = string
}

variable "service_plan_resource_id" {
  description = "The resource ID of the service plan to use for the function app"
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "managed_identity_principal_id" {
  description = "The principal id of the managed identity"
  type        = string
}

variable "managed_identity_id" {
  description = "The id of the managed identity"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "app_settings" {
  description = "The app settings of the function app"
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "The id of the Log Analytics workspace to send logs to"
  type        = string
}

variable "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  type        = string
}

variable "application_insights_key" {
  description = "The key for Application Insights"
  type        = string
}

variable "storage_account_share_name" {
  description = "The name of the storage account share"
  type        = string
}

variable "key_vault_reference_identity_id" {
  description = "The identity id for the Key Vault reference"
  type        = string
}

variable "storage_account_access_key" {
  description = "The access key for the storage account"
  type        = string
}
