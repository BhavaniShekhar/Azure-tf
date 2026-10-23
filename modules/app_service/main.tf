resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  resource_suffix = coalesce(var.resource_suffix, random_string.suffix.result)
}

resource "azurerm_resource_group" "app" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "app" {
  name                = "law-${var.app_name_prefix}-${local.resource_suffix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "app" {
  name                = "appi-${var.app_name_prefix}-${local.resource_suffix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.app.id
  retention_in_days   = 30
}

resource "azurerm_service_plan" "app" {
  name                = "asp-${var.app_name_prefix}-${local.resource_suffix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
}

data "archive_file" "webapp" {
  type        = "zip"
  source_dir  = var.app_source_dir
  output_path = "${path.root}/.terraform/${var.resource_group_name}-${var.app_name_prefix}-webapp.zip"
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.web_app_name_prefix}-${local.resource_suffix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  service_plan_id     = azurerm_service_plan.app.id
  https_only          = true
  zip_deploy_file     = data.archive_file.webapp.output_path

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app.connection_string
    APP_PACKAGE_HASH                      = data.archive_file.webapp.output_base64sha256
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "true"
  }

  site_config {
    always_on                         = true
    app_command_line                  = "npm start"
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 10

    application_stack {
      node_version = "20-lts"
    }
  }

  logs {
    application_logs {
      file_system_level = "Information"
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "app" {
  name                = "autoscale-${var.app_name_prefix}-${local.resource_suffix}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  target_resource_id  = azurerm_service_plan.app.id

  profile {
    name = "cpu-based-autoscale"

    capacity {
      default = var.default_instance_count
      minimum = var.min_instance_count
      maximum = var.max_instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT20M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }
}
