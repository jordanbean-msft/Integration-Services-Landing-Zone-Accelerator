resource "azapi_update_resource" "add_subnet_delegation_for_function_app_subnet" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2022-05-01"
  resource_id = var.function_app_subnet_resource_id

  body = {
    properties = {
      delegations = [
        {
          name = "web-delegation"
          properties = {
            serviceName = "Microsoft.Web/serverFarms"
          }
        }
      ]
    }
  }
}

resource "azapi_update_resource" "add_subnet_delegation_for_logic_app_subnet" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2022-05-01"
  resource_id = var.logic_app_subnet_resource_id

  body = {
    properties = {
      delegations = [
        {
          name = "web-delegation"
          properties = {
            serviceName = "Microsoft.Web/serverFarms"
          }
        }
      ]
    }
  }
}

resource "azapi_update_resource" "add_subnet_delegation_for_apim_subnet" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2022-05-01"
  resource_id = var.apim_subnet_resource_id

  body = {
    properties = {
      delegations = [
        {
          name = "apim-delegation"
          properties = {
            serviceName = "Microsoft.ApiManagement/service"
          }
        }
      ]
    }
  }
}
