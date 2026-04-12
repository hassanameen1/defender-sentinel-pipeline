variable "resource_group_name" {
  description = "Name of the resource group to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "law-secops-prod"
}

variable "retention_in_days" {
  description = "Data retention period in days (30 is free tier)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the workspace"
  type        = map(string)
  default     = {}
}
