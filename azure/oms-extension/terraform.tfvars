  vm_resource_group_name = "rg-webservers-weu"
  location = "westeurope"

  tags = {
    Owner          = "Nikolay Kyorov",
    CostCentre     = "NK17"
    DeploymentType = "Terraform"
  }

  # Storage account
  vm_storage_account = {
    account_tier = "Standard"
    replication_type ="LRS"
  }

  # Public IP
  vm_public_ip_name = "pip-webserver-001"
  vm_public_ip_allocation_method = "Static"

  # Network interface
  ip_configuration = {
    name                          = "ipconf1"
    private_ip_address_allocation = "Dynamic"
  }
  nic_name = "nic-webserver-001"

  # Linux VM
  vm_size = "Standard_B2s"
  vm_name = "vm-webserver-001"

  os_disk = {
    name                 = "OSDisk-webserver-001"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  os_image = {
    publisher = "RedHat"
    offer     = "rhel-raw"
    sku       = "8_4"
    version   = "latest"
  }


  # Network components
  vnet_rg = "rg-vnet-weu"
  vnet_name = "vnet-weu"
  vnet_address_spaces = ["10.0.0.0/16", "10.2.0.0/16"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names = ["lnx-clients", "win-clients", "mobile-clients"]
  nsg_name = "vnet-lnx-clients"

  log_analytics_workspace_name = "lasc16nskweu"
  log_analyics_rg_name = "rg-loganalytics-weu"
  oms_proxy = ""