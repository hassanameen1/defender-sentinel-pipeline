output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.secops.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.secops.location
}

output "law_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = module.log_analytics.workspace_id
}

output "law_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.log_analytics.workspace_name
}
