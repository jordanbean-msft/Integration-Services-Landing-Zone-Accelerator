resource "azapi_update_resource" "add_subnet_delegation_for_function_app_subnet" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2022-05-01"
  resource_id = var.function_app_subnet_resource_id

  body = {
    properties = {
      delegations = [
        {
          name = "delegation"
          properties = {
            serviceName = "Microsoft.App/environments" # this is needed for Function Apps Flex Consumption
          }
        }
      ]
    }
  }
}

resource "azapi_update_resource" "add_subnet_delegation_for_logic_app_subnet" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2022-05-01"
  resource_id = var.logic_app_subnet_resource_id
  depends_on  = [azapi_update_resource.add_subnet_delegation_for_function_app_subnet]

  body = {
    properties = {
      delegations = [
        {
          name = "delegation"
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
  depends_on  = [azapi_update_resource.add_subnet_delegation_for_logic_app_subnet]

  body = {
    properties = {
      delegations = [
        {
          name = "delegation"
          properties = {
            serviceName = "Microsoft.Web/serverFarms"
          }
        }
      ]
    }
  }
}
