output "logic_app_id" {
  description = "Resource ID of the Logic App"
  value       = azurerm_logic_app_workflow.this.id
}

output "trigger_callback_url" {
  description = "HTTP trigger URL — use this to manually test or wire into Sentinel automation rule"
  value       = azurerm_logic_app_trigger_http_request.incident.callback_url
  sensitive   = true
}

output "logic_app_principal_id" {
  description = "Principal ID of the Logic App managed identity"
  value       = length(azurerm_logic_app_workflow.this.identity) > 0 ? azurerm_logic_app_workflow.this.identity[0].principal_id : null
}
