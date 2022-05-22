output "public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.vm_network_interface.private_ip_address
}
