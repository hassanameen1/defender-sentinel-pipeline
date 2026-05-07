
variable "location" {
  description = "resource region"
  type        = string
}
variable "resource_group_name" {
  description = "the name of the group"
  type        = string
}
variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
variable "tenant_id" {
  description = "tenant_id"
  type        = string
}