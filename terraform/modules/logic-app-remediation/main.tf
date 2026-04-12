# Logic App: Auto-remediation playbook for public storage accounts
# Uses system-assigned managed identity to call ARM API — no stored credentials.

resource "azurerm_logic_app_workflow" "this" {
  name                = "logic-secops-remediation-prod"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# HTTP trigger — Sentinel automation rule POSTs to this URL when an incident fires
resource "azurerm_logic_app_trigger_http_request" "incident" {
  name         = "When_Sentinel_Incident_Fires"
  logic_app_id = azurerm_logic_app_workflow.this.id

  schema = jsonencode({
    type = "object"
    properties = {
      storageAccountResourceId = { type = "string" }
    }
  })
}

# Action 1: Call ARM API to disable public blob access
# Managed identity auth — no secrets required
resource "azurerm_logic_app_action_http" "remediate" {
  name         = "Disable_Public_Blob_Access"
  logic_app_id = azurerm_logic_app_workflow.this.id
  method       = "PATCH"
  uri          = "https://management.azure.com${var.storage_account_resource_id}?api-version=2023-01-01"

  headers = {
    "Content-Type" = "application/json"
  }

  body = jsonencode({
    properties = {
      allowBlobPublicAccess = false
    }
  })

  # NOTE: Managed identity authentication must be set via the portal designer after deployment.
  # The role assignment below grants the Logic App identity the rights to do so.
}

# Action 2: Post to Teams (only if webhook URL provided)
resource "azurerm_logic_app_action_http" "notify_teams" {
  count        = var.teams_webhook_url != "" ? 1 : 0
  name         = "Notify_Teams"
  logic_app_id = azurerm_logic_app_workflow.this.id
  method       = "POST"
  uri          = var.teams_webhook_url

  headers = {
    "Content-Type" = "application/json"
  }

  body = jsonencode({
    "@type"      = "MessageCard"
    "@context"   = "http://schema.org/extensions"
    summary      = "AUTO-REMEDIATION: Public blob access disabled"
    themeColor   = "0076D7"
    title        = "Sentinel Auto-Remediation Triggered"
    text         = "**Action:** Public blob access disabled on storage account\n\n**Resource:** ${var.storage_account_resource_id}\n\n**Triggered by:** Defender for Cloud → Sentinel\n\n**Status:** Remediated ✅"
  })

  run_after {
    action_name   = azurerm_logic_app_action_http.remediate.name
    action_result = "Succeeded"
  }
}

# Role assignment is created separately in root main.tf after identity is known
