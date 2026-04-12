resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  workspace_id = var.workspace_id
}

resource "azurerm_sentinel_alert_rule_scheduled" "public_storage_detection" {
  name                       = "detect-public-storage-account"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
  display_name               = "Defender: Public Blob Access Enabled on Storage Account"
  severity                   = "High"
  enabled                    = true

  query = <<-EOT
    SecurityRecommendation
    | where TimeGenerated > ago(5m)
    | where RecommendationState == "Active"
    | where RecommendationName has_any (
        "blob public access",
        "public access should be disallowed",
        "Blob public access should be disallowed",
        "Storage account public access"
    )
  EOT

  query_frequency = "PT5M"
  query_period    = "PT5M"

  trigger_operator  = "GreaterThan"
  trigger_threshold = 0
}
