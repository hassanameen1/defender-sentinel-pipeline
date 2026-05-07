variable "resource_group_name" {
  description = "rg name"
  type        = string

}
variable "location" {
  description = "rg location"
  type        = string
}
variable "resource_group_id" {
  description = "ARM resource ID of the resource group for RBAC scope"
  type        = string
}
