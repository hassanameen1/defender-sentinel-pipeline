resource "azurerm_logic_app_workflow" "logic-app" {
  name                = "logic-secops-remediation-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  identity {
    type = "SystemAssigned"
  }

}
resource "azurerm_role_assignment" "role_assignment_storage" {
  scope                = var.resource_group_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_logic_app_workflow.logic-app.identity[0].principal_id
}
