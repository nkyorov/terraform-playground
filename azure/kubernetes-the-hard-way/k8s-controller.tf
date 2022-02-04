resource "azurerm_availability_set" "as_controllers" {
  name                = var.controllers_avail_set_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_public_ip" "pip_controllers" {
  count               = var.controllers_count
  name                = "${local.pip_controller_prefix}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_network_interface" "nic_controllers" {
  count               = var.controllers_count
  name                = "nic-${local.k8s_controller_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.1${count.index + 1}"
    public_ip_address_id          = azurerm_public_ip.pip_controllers[count.index].id
  }
  enable_ip_forwarding = true

  tags = var.tags
}

resource "azurerm_network_interface_backend_address_pool_association" "associate_nics_to_lb" {
  count                   = var.controllers_count
  network_interface_id    = azurerm_network_interface.nic_controllers[count.index].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_addr_pool.id
}

resource "azurerm_linux_virtual_machine" "k8s_controllers" {
  count = var.controllers_count

  name                = "${local.k8s_controller_prefix}_${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic_controllers[count.index].id]

  os_disk {
    name                 = "OSDisk-${local.k8s_controller_prefix}-${count.index + 1}"
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
    storage_account_uri = azurerm_storage_account.stg_k8s.primary_blob_endpoint
  }

  availability_set_id = azurerm_availability_set.as_controllers.id

  admin_username                  = "kuberoot"
  computer_name                   = "k8s-controller-${count.index + 1}"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "kuberoot"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  tags = var.tags
}