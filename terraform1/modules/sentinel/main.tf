
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "secops" {
  workspace_id = var.workspace_id
}
resource "azurerm_sentinel_data_connector_azure_security_center" "secops" {
  name                       = "defender-for-cloud"
  log_analytics_workspace_id = var.workspace_id
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.secops]
}
resource "azurerm_security_center_setting" "sentinel_sync" {
  setting_name = "Sentinel"
  enabled      = true
  depends_on   = [azurerm_sentinel_log_analytics_workspace_onboarding.secops]
}
resource "azurerm_security_center_workspace" "secops" {
  scope        = "/subscriptions/${var.subscription_id}"
  workspace_id = var.workspace_id
}
resource "azurerm_sentinel_automation_rule" "auto_rule" {
  name                       = "00000000-0000-0000-0000-000000000001"
  log_analytics_workspace_id = var.workspace_id
  display_name               = "auto-remediate-public-storage"
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.secops]
  order                      = 1
  action_playbook {
    order        = 1
    logic_app_id = var.logic_app_id
  }
  
  condition_json = jsonencode([
  {
    conditionType = "Property"
    conditionProperties = {
      propertyName   = "IncidentRelatedAnalyticRuleIds"
      operator       = "Contains"
      propertyValues = [azurerm_sentinel_alert_rule_scheduled.public_storage.id]
    }
  }
])

}

resource "azurerm_sentinel_alert_rule_scheduled" "public_storage" {
  name                       = "public-storage-detection"
  log_analytics_workspace_id = var.workspace_id
  display_name               = "public storage Account detected"
  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.secops]
  severity                   = "High"
  query_frequency = "PT5M"
  query_period = "PT5M"
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  enabled = true
  
    query = <<-EOT
    SecurityRecommendation
    | where RecommendationState == "Unhealthy"
    | where RecommendationName has_any (
        "blob public access",
        "public access should be disallowed",
        "Blob public access should be disallowed",
        "Storage account public access"
    )
  EOT
}

resource "azurerm_role_assignment" "sentinel_playbook_operator" {
  scope                = var.resource_group_id
  role_definition_name = "Microsoft Sentinel Playbook Operator"
  principal_id         = "fc03cfe0-9484-4188-a8ce-0ca549768b37"
}