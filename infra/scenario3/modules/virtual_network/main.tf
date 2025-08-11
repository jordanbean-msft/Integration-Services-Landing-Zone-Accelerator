# resource "azapi_update_resource" "add_subnet_delegation_for_app_service_environment_subnet" {
#   type        = "Microsoft.Network/virtualNetworks/subnets@2022-05-01"
#   resource_id = var.app_service_environment_subnet_resource_id

#   body = {
#     properties = {
#       delegations = [
#         {
#           name = "delegation"
#           properties = {
#             serviceName = "Microsoft.Web/hostingEnvironments"
#           }
#         }
#       ]
#     }
#   }
# }

# resource "azapi_update_resource" "add_subnet_delegation_for_apim_subnet" {
#   type        = "Microsoft.Network/virtualNetworks/subnets@2022-05-01"
#   resource_id = var.apim_subnet_resource_id

#   body = {
#     properties = {
#       delegations = [
#         {
#           name = "delegation"
#           properties = {
#             serviceName = "Microsoft.Web/serverFarms"
#           }
#         }
#       ]
#     }
#   }
# }
