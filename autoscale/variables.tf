variable "location" {
  description = "Azure region for the resources."
  type        = string
  default     = "southindia"
}

variable "resource_group_name" {
  description = "Name of the resource group to create."
  type        = string
  default     = "rg-appservice-autoscale-demo"
}

variable "app_name_prefix" {
  description = "Prefix used for the App Service Plan and monitoring resource names."
  type        = string
  default     = "appservice"
}

variable "web_app_name_prefix" {
  description = "Prefix used for the globally unique Web App name."
  type        = string
  default     = "web"
}

variable "resource_suffix" {
  description = "Optional six-character suffix for resource names; leave null to generate one."
  type        = string
  default     = "9equss"
  nullable    = true
}

variable "service_plan_sku" {
  description = "SKU for the Linux App Service Plan."
  type        = string
  default     = "S1"
}

variable "min_instance_count" {
  description = "Minimum number of App Service Plan instances."
  type        = number
  default     = 1
}

variable "default_instance_count" {
  description = "Default number of App Service Plan instances."
  type        = number
  default     = 1
}

variable "max_instance_count" {
  description = "Maximum number of App Service Plan instances."
  type        = number
  default     = 3
}
