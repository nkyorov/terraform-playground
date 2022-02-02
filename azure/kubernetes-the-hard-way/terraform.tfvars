rg_name     = "kubernetes"
rg_location = "westeurope"

vnet_name           = "kubernetes-vnet"
vnet_address_spaces = ["10.240.0.0/24"]
subnet_prefixes     = ["10.240.0.0/24"]
subnet_names        = ["kubernetes-subnet"]
nsg_name            = "kubernetes-nsg"

lb_name = "kubernetes-lb"
pip_lb_name = "kubernetes-pip"
pip_lb_alloc = "Static"

tags = {
  Owner   = "Nikolay Kyorov"
  Project = "Kubernetes The Hard Way on Azure"
}