output "resource_group_name" {
  description = "RG name"
  value       = azurerm_resource_group.secops.name
}
output "resource_group_location" {
  description = "RG loaction"
  value       = azurerm_resource_group.secops.location
}
output "workspace_id" {
  description = "the workspace_id"
  value       = azurerm_log_analytics_workspace.secops.id
}
output "tenant_id" {
  description = "tenat id "
  value       = data.azurerm_client_config.current.tenant_id
}
output "resource_group_id" {
  description = "ARM resource ID of the resource group"
  value       = azurerm_resource_group.secops.id
}