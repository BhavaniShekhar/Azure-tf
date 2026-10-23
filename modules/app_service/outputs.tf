output "web_app_url" {
  description = "HTTPS URL of the web app."
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "web_app_name" {
  description = "Globally unique name of the deployed web app."
  value       = azurerm_linux_web_app.app.name
}

output "app_insights_name" {
  description = "Application Insights resource name."
  value       = azurerm_application_insights.app.name
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  value       = azurerm_log_analytics_workspace.app.name
}

output "app_service_plan_id" {
  description = "App Service Plan ID targeted by the autoscale setting."
  value       = azurerm_service_plan.app.id
}
