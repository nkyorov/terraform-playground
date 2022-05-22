resource "azurerm_resource_group" "vm_resource_group" {
  name     = var.vm_resource_group_name
  location = var.location

  tags = var.tags
}

resource "random_id" "randomId" {
  byte_length = 8
}

resource "azurerm_storage_account" "vm_storage_account" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.vm_resource_group.name
  location                 = var.location
  account_tier             = var.vm_storage_account.account_tier
  account_replication_type = var.vm_storage_account.replication_type

  tags = var.tags
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = var.vm_public_ip_name
  resource_group_name = azurerm_resource_group.vm_resource_group.name
  location            = var.location
  allocation_method   = var.vm_public_ip_allocation_method

  tags = var.tags
}

resource "azurerm_network_interface" "vm_network_interface" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.vm_resource_group_name

  ip_configuration {
    name                          = var.ip_configuration.name
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = var.ip_configuration.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  name                = var.vm_name
  resource_group_name = var.vm_resource_group_name
  location            = var.location
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.vm_network_interface.id]
  
  os_disk {
    name                 = var.os_disk.name
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.vm_storage_account.primary_blob_endpoint
  }

  computer_name                   = "web.rhel8"
  admin_username                  = "nkyorov"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "nkyorov"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  tags = var.tags

}
