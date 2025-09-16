variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "name_suffix" {
  description = "A suffix to append to the resource names for uniqueness."
  type        = string
}

variable "principal_id" {
  description = "The Id of the service principal to add to deployed keyvault access policies"
  type        = string
}

variable "access_policy_object_ids" {
  description = "A list of object ids to be be added to the keyvault access policies"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "A list of secrets to be added to the keyvault"
  type = list(object({
    name  = string
    value = string
  }))
  sensitive = true
}

variable "subnet_id" {
  description = "The resource id of the subnet to deploy the private endpoint into"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  type        = string
}
