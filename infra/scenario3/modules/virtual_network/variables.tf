variable "private_endpoint_subnet_resource_id" {
  description = "The resource ID of the subnet where the private endpoint will be created"
  type        = string
}

variable "apim_subnet_resource_id" {
  description = "The resource ID of the subnet for the APIM"
  type        = string
}

variable "logic_app_subnet_resource_id" {
  description = "The resource ID of the subnet for the Logic App"
  type        = string
}

variable "function_app_subnet_resource_id" {
  description = "The resource ID of the subnet for the Function App"
  type        = string
}
