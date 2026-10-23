terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

module "app_service" {
  source = "./modules/app_service"

  location               = var.location
  resource_group_name    = var.resource_group_name
  app_source_dir         = "${path.root}/app"
  app_name_prefix        = var.app_name_prefix
  web_app_name_prefix    = var.web_app_name_prefix
  resource_suffix        = var.resource_suffix
  service_plan_sku       = var.service_plan_sku
  min_instance_count     = var.min_instance_count
  default_instance_count = var.default_instance_count
  max_instance_count     = var.max_instance_count
}
