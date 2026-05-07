variable "subscription_id" {
  description = "azure subs id to deploy"
  type        = string
}
variable "location" {
  description = "resource region"
  type        = string

}
variable "resource_group_name" {
  description = "the name of the group"
  type        = string
}
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
variable "workspace_id" {
  description = "The LAW workspace resource ID"
  type        = string
} 