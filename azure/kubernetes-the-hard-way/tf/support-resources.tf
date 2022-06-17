resource "azurerm_resource_group" "resource_group" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

resource "random_id" "randomId" {
  byte_length = 8
}

resource "azurerm_storage_account" "stg_acc_k8s" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

