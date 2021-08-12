output "storage_account_name" {
  value = azurerm_storage_account.stg_acc.name
}

output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}