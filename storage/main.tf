terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vybhava" {
  name     = "rg-blob-test"
  location = "Southeast Asia"
}

resource "azurerm_storage_account" "vybhava" {
  name                     = "vybhavastorageacct07" # Must be globally unique, lowercase, 3-24 chars
  resource_group_name      = azurerm_resource_group.vybhava.name
  location                 = azurerm_resource_group.vybhava.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "vybhava" {
  name                  = "content"
  storage_account_id    = azurerm_storage_account.vybhava.id
  container_access_type = "private"
}

variable "pavan_object_id" {
  description = "Object ID of Pavan in Microsoft Entra ID"
  type        = string
}

variable "bhavani_object_id" {
  description = "Object ID of Bhavani in Microsoft Entra ID"
  type        = string
}

resource "azurerm_role_assignment" "pavan_blob_write" {
  scope                = azurerm_storage_container.vybhava.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.pavan_object_id
}

resource "azurerm_role_assignment" "bhavani_blob_read" {
  scope                = azurerm_storage_container.vybhava.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.bhavani_object_id
}

output "storage_connection_string" {
  value     = azurerm_storage_account.vybhava.primary_connection_string
  sensitive = true
}