
resource "azurerm_resource_group" "secops" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
resource "azurerm_log_analytics_workspace" "secops" {
  name                = "law-secops-prod"
  location            = azurerm_resource_group.secops.location
  resource_group_name = azurerm_resource_group.secops.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}
resource "azurerm_log_analytics_solution" "security_center_free" {
  solution_name         = "SecurityCenterFree"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.secops.id
  workspace_name        = azurerm_log_analytics_workspace.secops.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityCenterFree"
  }
}

data "azurerm_client_config" "current" {}