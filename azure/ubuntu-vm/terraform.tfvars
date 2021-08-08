rg_name          = "terraform-demo"
vm_name          = "terraform-demo"
vnet_name        = "terraform-demo"
subnet_name      = "terraform-demo"
location         = "westeurope"
billing_code_tag = 4231495

subnet_count = {
  Development = 2
  QA          = 2
  Production  = 3
}

instance_count = {
  Development = 2
  QA          = 4
  Production  = 6
}

instance_size = {
  Development = "Standard_B2s"
  QA          = "Standard_B2s"
  Production  = "Standard_DS1_v2"
}

network_address_space = {
  Development = "10.0.0.0/16"
  QA          = "10.1.0.0/16"
  Production  = "10.2.0.0/16"
}