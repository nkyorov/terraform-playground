# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  name     = var.rg_name
  location = var.location
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.resource_group.name
  }
  byte_length = 8
}

# Create storage account to store the state
resource "azurerm_storage_account" "stg_acc" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create the container
resource "azurerm_storage_container" "stg_container" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.stg_acc.name
}

# Create SAS Token
data "azurerm_storage_account_sas" "sas_token" {
  connection_string = azurerm_storage_account.stg_acc.primary_connection_string
  https_only        = true

  # Interact with
  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  # Set validity of token
  start  = timestamp()
  expiry = timeadd(timestamp(), "48h")

  # Token permissions
  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
  }
}

resource "local_file" "post-config" {
  depends_on = [azurerm_storage_container.stg_container]

  filename = "${path.module}/backend-config.txt"
  content  = <<EOF
storage_account_name = "${azurerm_storage_account.stg_acc.name}"
container_name = "terraform-state"
key = "terraform.tfstate"
sas_token = "${data.azurerm_storage_account_sas.sas_token.sas}"
  EOF
}