
variable "location" {
  description = "The Azure location to deploy the resources"
  type        = string
}


variable "resource_group_name" {
  description = "The name of the resource group where resources will be created"
  type        = string
}


variable "environment_name" {
  description = "The name of the environment, used for tagging and resource naming"
  type        = string
}

variable "principal_id" {
  description = "The principal ID of the user to assign roles to"
  type        = string
}


variable "logic_app" {
  description = "Configuration for the Logic App"
  type = object({
    storage_account_account_tier             = string
    storage_account_account_replication_type = string
    storage_account_file_share_quota         = number
    sku_name                                 = string
    worker_count                             = number
    website_dns_server                       = string
  })
}

variable "function_app" {
  description = "Configuration for the Function App"
  type = object({
    storage_account_account_tier             = string
    storage_account_account_replication_type = string
    sku_name                                 = string
    worker_count                             = number
  })
}

# Network block updated to match main.tfvars.json
variable "network" {
  description = "Network configuration for the resources"
  type = object({
    virtual_network_name                = string
    virtual_network_resource_group_name = string
    private_endpoint_subnet_name        = string
    apim_subnet_name                    = string
    logic_app_subnet_name               = string
    function_app_subnet_name            = string
  })
}

# APIM
variable "apim" {
  description = "Configuration for Azure API Management"
  type = object({
    publisher_name  = string
    publisher_email = string
    sku_name        = string
    sku_capacity    = number
    zones           = list(string)
  })
}


variable "zone_redundancy_enabled" {
  description = "Enable or disable zone redundancy for the Cosmos DB account"
  type        = bool
}

variable "service_bus" {
  description = "Configuration for Azure Service Bus"
  type = object({
    sku_name     = string
    sku_capacity = number
  })
}

variable "sql" {
  description = "Configuration for Azure SQL Database"
  type = object({
    sku_name = string
  })
}

variable "file_storage_storage_account" {
  description = "Configuration for Azure File Storage Account"
  type = object({
    account_tier             = string
    account_replication_type = string
  })
}
