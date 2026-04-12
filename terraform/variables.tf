variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "uaenorth"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-secops-prod"
}

variable "teams_webhook_url" {
  description = "Teams Incoming Webhook URL for auto-remediation notifications"
  type        = string
  default     = ""
  sensitive   = true
}
