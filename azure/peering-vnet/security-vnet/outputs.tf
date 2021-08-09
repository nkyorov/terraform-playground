output "vnet_id" {
  value = module.vnet-security.vnet_id
}

output "vnet_name" {
  value = module.vnet-security.vnet_name
}

output "service_principal_client_id" {
  value = azuread_service_principal.sp.id
}

output "resource_group_name" {
  value = var.resource_group_name
}