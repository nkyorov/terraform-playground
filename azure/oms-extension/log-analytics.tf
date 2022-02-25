resource "azurerm_resource_group" "log_analytics_resource_group" {
  name     = var.log_analyics_rg_name
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.log_analytics_resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_machine_extension" "oms_extension" {
 name                          = "OMSExtension"
 virtual_machine_id            = azurerm_linux_virtual_machine.linux_virtual_machine.id 
 publisher                     = "Microsoft.EnterpriseCloud.Monitoring"
 type                          = "OmsAgentForLinux"
 type_handler_version          = "1.14"
 auto_upgrade_minor_version    = true

 settings = <<-BASE_SETTINGS
 {
   "workspaceId" : "${azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id}"
 }
 BASE_SETTINGS

 protected_settings = <<-PROTECTED_SETTINGS
 {
   "workspaceKey" : "${azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key}",
   "proxy" : "${var.oms_proxy}"
 }
 PROTECTED_SETTINGS
 
}