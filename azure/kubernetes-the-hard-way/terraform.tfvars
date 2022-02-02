rg_name     = "kubernetes"
rg_location = "westeurope"

vnet_name           = "kubernetes-vnet"
vnet_address_spaces = ["10.240.0.0/24"]
subnet_prefixes     = ["10.240.0.0/24"]
subnet_names        = ["kubernetes-subnet"]
nsg_name            = "kubernetes-nsg"


lb_name      = "kubernetes-lb"
pip_lb_name  = "kubernetes-pip"
pip_lb_alloc = "Static"

controllers_avail_set_name    = "controllers-as"
workers_avail_set_name    = "workers-as"


vm_size           = "Standard_B2s"
controllers_count = 3
workers_count = 2 


os_image = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}

tags = {
  Owner   = "Nikolay Kyorov"
  Project = "Kubernetes The Hard Way on Azure"
}