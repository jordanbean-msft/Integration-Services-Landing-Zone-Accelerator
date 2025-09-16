variable "private_endpoint_subnet_resource_id" {
  description = "The resource ID of the subnet where the private endpoint will be created"
  type        = string
}

variable "apim_subnet_resource_id" {
  description = "The resource ID of the subnet for the APIM"
  type        = string
}

variable "app_service_environment_subnet_resource_id" {
  description = "The resource ID of the subnet for the App Service Environment"
  type        = string
}
