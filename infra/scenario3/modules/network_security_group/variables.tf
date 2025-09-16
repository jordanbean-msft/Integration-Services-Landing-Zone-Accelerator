variable "name_suffix" {
  description = "Suffix for the name of the Network Security Group."
  type        = string
}

variable "location" {
  description = "The Azure location to deploy the Network Security Group."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}



variable "tags" {
  description = "Tags to be applied to the Network Security Group."
  type        = map(string)
}


variable "security_rules" {
  description = "Map of NSG rules to apply to the Network Security Group."
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_range     = optional(string)
    destination_port_ranges    = optional(list(string))
  }))
  default = {}
}
