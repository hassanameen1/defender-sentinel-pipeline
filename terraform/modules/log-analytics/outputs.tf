output "workspace_id" {
  description = "Resource ID of the Log Analytics Workspace (used by Sentinel, Defender export)"
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "primary_shared_key" {
  description = "Primary shared key for the workspace (sensitive)"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}
