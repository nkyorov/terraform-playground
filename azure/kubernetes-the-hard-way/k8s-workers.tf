resource "azurerm_availability_set" "availability_set_workers" {
  name                = var.workers_avail_set_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  tags = var.tags

}

resource "azurerm_public_ip" "public_ip_workers" {
  count               = var.workers_count
  name                = "${local.pip_worker_prefix}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_network_interface" "network_interface_workers" {
  count               = var.workers_count
  name                = "nic-${local.k8s_worker_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.2${count.index + 1}"
    public_ip_address_id          = azurerm_public_ip.public_ip_workers[count.index].id
  }
  enable_ip_forwarding = true

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "k8s_workers" {
  count = var.workers_count

  name                = "${local.k8s_worker_prefix}_${count.index + 1}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.network_interface_workers[count.index].id]

  os_disk {
    name                 = "OSDisk-${local.k8s_worker_prefix}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.stg_acc_k8s.primary_blob_endpoint
  }

  availability_set_id = azurerm_availability_set.availability_set_workers.id

  admin_username                  = "kuberoot"
  computer_name                   = "k8s-worker-${count.index + 1}"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "kuberoot"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  tags = var.tags
}
