variable "location" {
  description = "Azure region for the resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create."
  type        = string
}

variable "app_source_dir" {
  description = "Path to the directory containing the web app source."
  type        = string
}

variable "app_name_prefix" {
  description = "Prefix used for the App Service Plan and monitoring resource names."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.app_name_prefix))
    error_message = "app_name_prefix must contain only letters, numbers, and hyphens."
  }
}

variable "web_app_name_prefix" {
  description = "Prefix used for the globally unique Web App name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.web_app_name_prefix))
    error_message = "web_app_name_prefix must contain only letters, numbers, and hyphens."
  }
}

variable "resource_suffix" {
  description = "Optional six-character suffix for resource names; leave null to generate one."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.resource_suffix == null || can(regex("^[a-z0-9]{6}$", var.resource_suffix))
    error_message = "resource_suffix must be null or exactly six lowercase letters or digits."
  }
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

  validation {
    condition = (
      var.min_instance_count >= 1 &&
      var.min_instance_count <= var.default_instance_count &&
      var.default_instance_count <= var.max_instance_count
    )
    error_message = "Instance counts must satisfy 1 <= minimum <= default <= maximum."
  }
}
