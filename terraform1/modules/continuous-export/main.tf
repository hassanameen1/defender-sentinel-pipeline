data "azurerm_client_config" "current" {
}

resource "azurerm_security_center_automation" "secops" {
  name                = "con-export"
  location            = var.location
  resource_group_name = var.resource_group_name

  enabled = true

  action {
    type        = "loganalytics"
    resource_id = var.workspace_id
  }

  source {
    event_source = "Alerts"

  }
  source {
    event_source = "Assessments"
  }
  source {
    event_source = "SecureScores"

  }
  source {
    event_source = "RegulatoryComplianceAssessment"

  }

  scopes = ["/subscriptions/${var.subscription_id}"]
}
