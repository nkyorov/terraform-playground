terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vnet_main" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet-main" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.vnet_main.name
  vnet_name           = var.resource_group_name
  address_space       = [var.vnet_address_space]
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  depends_on = [azurerm_resource_group.vnet_main]
}