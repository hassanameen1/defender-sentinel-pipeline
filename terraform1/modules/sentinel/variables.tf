variable "workspace_id" {
  description = "defining workspace id"
  type        = string
}
variable "subscription_id" {
  description = "azure subs id to deploy"
  type        = string
}
variable "logic_app_id" {
  description = "logic app arm id"
  type        = string
}
variable "resource_group_id" {
  description = "ARM resource ID of the resource group for RBAC scope"
  type        = string
}
