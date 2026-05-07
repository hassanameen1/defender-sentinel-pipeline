variable "subscription_id" {
  description = "azure subs id to deploy"
  type        = string
}
variable "location" {
  description = "resource region"
  type        = string
  default     = "uaenorth"
}
variable "resource_group_name" {
  description = "the name of the group"
  type        = string
  default     = "rg-secops-prod"
}
variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}           