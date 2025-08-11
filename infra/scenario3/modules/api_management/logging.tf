resource "azurerm_api_management_logger" "application_insights_logging" {
  api_management_name = module.api_management.name
  resource_group_name = var.resource_group_name
  name                = "application-insights-logger"
  resource_id         = var.application_insights_id
  application_insights {
    instrumentation_key = var.application_insights_instrumentation_key
  }
}
