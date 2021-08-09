terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

data "azurerm_subscription" "current" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "security-rg" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet-security" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.security-rg.name
  vnet_name           = var.resource_group_name
  address_space       = [var.vnet_address_space]
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  tags = {
    environment = "security"
    costcenter  = "security"

  }

  depends_on = [azurerm_resource_group.security-rg]
}

# Create an application
resource "azuread_application" "app" {
  display_name = "vnet-peer"
}

# Create SPN
resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}

resource "azuread_service_principal_password" "pass" {
  service_principal_id = azuread_service_principal.sp.id
}

# Create role definition
resource "azurerm_role_definition" "role_definition" {
  name  = "allow-vnet-peering"
  scope = data.azurerm_subscription.current.id

  permissions {
    actions        = ["Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write", "Microsoft.Network/virtualNetworks/peer/action", "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read", "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

resource "azurerm_role_assignment" "role_assignment" {
  scope              = module.vnet-security.vnet_id
  role_definition_id = azurerm_role_definition.role_definition.role_definition_resource_id
  principal_id       = azuread_service_principal.sp.id
}





# resource "local_file" "linux" {
#   filename = "${path.module}/next-step.txt"
#   content  = <<EOF
# export TF_VAR_sec_vnet_id=${module.vnet-sec.vnet_id}

# export TF_VAR_sec_vnet_name=${module.vnet-sec.vnet_name}
# export TF_VAR_sec_sub_id=${data.azurerm_subscription.current.subscription_id}
# export TF_VAR_sec_client_id=${azuread_service_principal.vnet_peering.application_id}
# export TF_VAR_sec_principal_id=${azuread_service_principal.vnet_peering.id}
# export TF_VAR_sec_client_secret='${random_password.vnet_peering.result}'
# export TF_VAR_sec_resource_group=${var.sec_resource_group_name}
# export TF_VAR_sec_tenant_id=${data.azurerm_subscription.current.tenant_id}

#   EOF
# }

resource "local_file" "windows" {
  filename = "${path.module}/ids.txt"
  content  = <<EOF
$env:TF_VAR_sec_vnet_id="${module.vnet-security.vnet_id}"
$env:TF_VAR_sec_vnet_name="${module.vnet-security.vnet_name}"
$env:TF_VAR_sec_sub_id="${data.azurerm_subscription.current.subscription_id}"
$env:TF_VAR_sec_client_id="${azuread_service_principal.sp.application_id}"
$env:TF_VAR_sec_client_secret="${azuread_service_principal_password.pass.value}"
$env:TF_VAR_sec_principal_id="${azuread_service_principal.sp.id}"
$env:TF_VAR_sec_resource_group="${var.resource_group_name}"
$env:TF_VAR_sec_tenant_id="${data.azurerm_subscription.current.tenant_id}"

  EOF
}
