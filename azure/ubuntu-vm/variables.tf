# Variables
variable "rg_name" {}
variable "vm_name" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "location" {
  default = "westeurope"
}
variable "billing_code_tag" {}
variable "network_address_space" {
  type = map(string)
}
variable "subnet_count" {
  type = map(number)
}

variable "instance_count" {
  type = map(number)
}

variable "instance_size" {
  type = map(string)
}

# Locals
locals {
  env_name = lower(terraform.workspace)

  common_tags = {
    Environment = local.env_name
    BillingCode = var.billing_code_tag
  }

  nic_name  = "nic-${var.vm_name}"
  public_ip = "pip-${var.vm_name}"
  nsg_name  = "nsg-${var.subnet_name}"

  rg_name     = "rg-${local.env_name}-${var.rg_name}"
  vm_name     = "vm-${var.vm_name}"
  vnet_name   = "vnet-${var.vnet_name}"
  subnet_name = "snet-${var.subnet_name}"
}
