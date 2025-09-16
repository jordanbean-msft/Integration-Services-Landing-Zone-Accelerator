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

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "private_endpoint_subnet_id" {
  description = "The subnet id to deploy the private endpoint into."
  type        = string
}

variable "managed_identity_principal_id" {
  description = "The principal id of the managed identity"
  type        = string
}

variable "managed_identity_id" {
  description = "The id of the managed identity"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The id of the Log Analytics workspace to send logs to"
  type        = string
}

variable "sku" {
  description = "The SKU of the Service Bus Namespace"
  type        = string
}

variable "capacity" {
  description = "The capacity of the Service Bus Namespace"
  type        = number
}
