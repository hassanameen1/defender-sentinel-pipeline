variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID of the resource group (for role assignment)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "storage_account_resource_id" {
  description = "Full ARM resource ID of the storage account to remediate"
  type        = string
}

variable "teams_webhook_url" {
  description = "Teams Incoming Webhook URL for notifications (leave empty to skip)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
