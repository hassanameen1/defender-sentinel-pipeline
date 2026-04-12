resource "azurerm_application_insights_workbook" "secops_dashboard" {
  name                = "c20aa3aa-b885-4610-8dc0-23a4f5a55bdb"
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "SecOps — Defender & Sentinel Dashboard"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "# SecOps — Defender for Cloud + Sentinel Dashboard\n---\nSecure Score trend, active recommendations, and auto-remediation events."
        }
        name = "header"
      },
      {
        type = 9
        content = {
          version = "KqlParameterItem/1.0"
          parameters = [
            {
              id        = "timeRange"
              version   = "KqlParameterItem/1.0"
              name      = "TimeRange"
              type      = 4
              isRequired = true
              value = {
                durationMs = 2592000000
              }
              label = "Time Range"
            }
          ]
        }
        name = "parameters"
      },
      {
        type = 1
        content = {
          json = "## Secure Score Trend"
        }
        name = "secure-score-title"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "SecureScores\n| where TimeGenerated {TimeRange}\n| project TimeGenerated, Score = round(PercentageScore * 100, 1)\n| order by TimeGenerated asc"
          size         = 0
          title        = "Secure Score (%) over time"
          timeContext  = { durationMs = 2592000000 }
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          visualization = "linechart"
          chartSettings = {
            yAxis = [{ column = "Score", label = "Score %" }]
          }
        }
        name = "secure-score-chart"
      },
      {
        type = 1
        content = {
          json = "## Top Active Recommendations"
        }
        name = "recommendations-title"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "SecurityRecommendation\n| where TimeGenerated {TimeRange}\n| where RecommendationState == \"Active\"\n| summarize Count = count() by RecommendationName, RecommendationSeverity\n| order by Count desc\n| take 10"
          size         = 0
          title        = "Top 10 Active Recommendations"
          timeContext  = { durationMs = 86400000 }
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          visualization = "table"
          gridSettings = {
            sortBy = [{ itemKey = "Count", sortOrder = 2 }]
          }
        }
        name = "top-recommendations"
      },
      {
        type = 1
        content = {
          json = "## Security Alerts"
        }
        name = "alerts-title"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "SecurityAlert\n| where TimeGenerated {TimeRange}\n| summarize Count = count() by AlertSeverity, AlertName\n| order by Count desc\n| take 10"
          size         = 0
          title        = "Recent Security Alerts by Severity"
          timeContext  = { durationMs = 2592000000 }
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          visualization = "table"
        }
        name = "security-alerts"
      }
    ]
    styleSettings = {}
    "$schema" = "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

  tags = var.tags
}
