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