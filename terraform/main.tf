locals {
  tags = {
    project     = "defender-sentinel"
    environment = "prod"
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "secops" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "log_analytics" {
  source = "./modules/log-analytics"

  resource_group_name = azurerm_resource_group.secops.name
  location            = azurerm_resource_group.secops.location
  workspace_name      = "law-secops-prod"
  retention_in_days   = 30
  tags                = local.tags
}

module "logic_app_remediation" {
  source = "./modules/logic-app-remediation"

  resource_group_name         = azurerm_resource_group.secops.name
  resource_group_id           = azurerm_resource_group.secops.id
  location                    = azurerm_resource_group.secops.location
  storage_account_resource_id = azurerm_storage_account.public_demo.id
  teams_webhook_url           = var.teams_webhook_url
  tags                        = local.tags
}

# Role assignment added after Logic App identity is known
resource "azurerm_role_assignment" "logic_app_storage" {
  scope                = azurerm_resource_group.secops.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = module.logic_app_remediation.logic_app_principal_id

  depends_on = [module.logic_app_remediation]
}

module "sentinel" {
  source = "./modules/sentinel"

  resource_group_name = azurerm_resource_group.secops.name
  location            = azurerm_resource_group.secops.location
  workspace_id        = module.log_analytics.workspace_id
  workspace_name      = module.log_analytics.workspace_name
}
