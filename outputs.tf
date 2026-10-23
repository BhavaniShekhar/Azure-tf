output "web_app_url" {
  description = "HTTPS URL of the sample web app."
  value       = module.app_service.web_app_url
}

output "web_app_name" {
  description = "Globally unique name of the deployed web app."
  value       = module.app_service.web_app_name
}

output "app_insights_name" {
  description = "Application Insights resource for application telemetry."
  value       = module.app_service.app_insights_name
}

output "log_analytics_workspace_name" {
  description = "Workspace receiving Application Insights telemetry."
  value       = module.app_service.log_analytics_workspace_name
}

output "app_service_plan_id" {
  description = "App Service Plan ID targeted by the autoscale setting."
  value       = module.app_service.app_service_plan_id
}
