variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "name_suffix" {
  description = "A suffix string to centrally mitigate resource name collisions."
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "publisher_email" {
  description = "The API Management publisher email"
  type        = string
}

variable "publisher_name" {
  description = "The API Management publisher name"
  type        = string
}

variable "sku_name" {
  description = "The API Management SKU"
  type        = string
}

variable "sku_capacity" {
  description = "The API Management SKU capacity"
  type        = number
}

variable "user_assigned_identity_id" {
  description = "The User Assigned Managed Identity to assign to the API Management portal"
  type        = string
}

variable "user_assigned_identity_client_id" {
  description = "The User Assigned Managed Identity client ID to assign to the API Management portal"
  type        = string
}

variable "user_assigned_identity_principal_id" {
  description = "The User Assigned Managed Identity principal ID to assign to the API Management portal"
  type        = string
}

variable "api_management_subnet_id" {
  description = "The subnet ID to associate to the API Management portal"
  type        = string
}

variable "application_insights_instrumentation_key" {
  description = "The Application Insights key to use for the API Management service"
  type        = string
  sensitive   = true
}

variable "application_insights_id" {
  description = "The Application Insights ID to use for the API Management service"
  type        = string
}

variable "key_vault_id" {
  description = "The Key Vault ID to use for the API Management service"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID to use for the API Management service"
  type        = string
}

variable "zones" {
  description = "The availability zones to use for the API Management service"
  type        = list(string)
}

variable "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID to use for the API Management service"
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID to use for the API Management service"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "The subnet ID to use for the private endpoint"
  type        = string
}
