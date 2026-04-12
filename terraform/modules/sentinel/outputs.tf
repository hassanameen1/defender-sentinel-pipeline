output "sentinel_workspace_id" {
  description = "Resource ID of the Sentinel-onboarded workspace"
  value       = azurerm_sentinel_log_analytics_workspace_onboarding.this.workspace_id
}
