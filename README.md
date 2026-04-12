# Defender for Cloud → Sentinel Auto-Remediation Pipeline

A closed-loop cloud security pipeline that detects misconfigured Azure resources and automatically remediates them — before an attacker finds them.

**Detection → Alert → Remediation in under 60 seconds. Zero human involvement.**

---

## The Problem

Cloud environments drift into insecure states constantly. Public storage accounts, open firewall rules, unencrypted disks — misconfiguration is the #1 cause of cloud breaches (Capital One, Microsoft AI research leak, countless ransomware incidents).

Most teams turn Defender for Cloud on and stop there. They get a list of findings and humans triage hundreds of tickets. This project closes the loop.

---

## Architecture

```
Azure Subscription (UAE North)
  └── Microsoft Defender for Cloud
        ├── All plans enabled (Servers, Storage, Databases, Key Vault, ARM, Containers)
        ├── Regulatory compliance: MCSB, CIS Azure Foundations
        └── Continuous Export
                  ↓
        Log Analytics Workspace (law-secops-prod)
                  ↓
        Microsoft Sentinel
                  ├── KQL Scheduled Detection Rule
                  │     └── Fires when public blob access found → creates Incident
                  ├── Automation → Logic App Playbook
                  │     ├── ARM API call: set allowBlobPublicAccess = false
                  │     └── Microsoft Teams notification
                  └── Workbook: Secure Score trend + Top recommendations
```

---

## What It Does

1. A storage account is created with `allowBlobPublicAccess = true` (a common misconfiguration)
2. Defender for Cloud detects it and pushes the finding to the Log Analytics Workspace via Continuous Export
3. A Sentinel KQL detection rule runs every 5 minutes, finds the active recommendation, and creates a Sentinel incident
4. A Logic App playbook fires — it calls the Azure Resource Manager API using a **system-assigned managed identity** (no stored credentials) to set `allowBlobPublicAccess = false`
5. Microsoft Teams receives a notification: *"Auto-remediation complete"*
6. Defender re-scans, the finding resolves, Secure Score improves

**Time from misconfiguration to fix: under 60 seconds.**

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Cloud | Microsoft Azure |
| IaC | Terraform (`azurerm` provider ~4.0) |
| CSPM | Microsoft Defender for Cloud |
| SIEM | Microsoft Sentinel |
| Detection | KQL (Kusto Query Language) |
| Automation | Azure Logic Apps (Consumption tier) |
| Auth | System-assigned Managed Identity |
| Notifications | Microsoft Teams |
| Region | UAE North |

---

## Repository Structure

```
defender-sentinel-project/
├── terraform/
│   ├── main.tf                          # Root module — wires everything together
│   ├── variables.tf                     # Input variables
│   ├── outputs.tf                       # Output values
│   ├── versions.tf                      # Provider version pins (azurerm ~4.0)
│   ├── misconfigs.tf                    # Deliberate misconfigurations for demo
│   ├── terraform.tfvars.example         # Template — copy to terraform.tfvars
│   └── modules/
│       ├── log-analytics/               # Log Analytics Workspace
│       ├── sentinel/                    # Sentinel onboarding + KQL rule + Workbook
│       └── logic-app-remediation/       # Logic App playbook + role assignment
├── kql/
│   ├── detection-public-storage.kql    # Sentinel scheduled detection rule
│   └── workbook-queries/
│       ├── secure-score-trend.kql
│       └── top-recommendations.kql
├── logic-apps/
│   └── remediate-public-storage.json   # Logic App ARM definition
├── screenshots/                         # Build evidence for LinkedIn/portfolio
├── BUILD_LOG.md                         # Session-by-session build notes
└── README.md
```

---

## Deploy It Yourself

### Prerequisites

- Azure subscription (free trial works)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0

### Steps

```bash
# 1. Clone the repo
git clone <repo-url>
cd defender-sentinel-project

# 2. Authenticate to Azure
az login
az account set --subscription "<your-subscription-id>"

# 3. Configure variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your subscription ID

# 4. Deploy
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Post-deploy portal steps

1. **Enable Defender plans:** Defender for Cloud → Environment Settings → your subscription → enable all plans
2. **Configure Continuous Export:** Environment Settings → Continuous Export → Log Analytics workspace → select `law-secops-prod`
3. **Enable Managed Identity auth on Logic App:** Logic App Designer → `Disable_Public_Blob_Access` action → Authentication → Managed Identity

### Trigger a demo

```bash
# Re-enable the misconfiguration (Terraform manages this)
cd terraform && terraform apply  # resets storage account to misconfigured state

# Or manually trigger the Logic App to test remediation
curl -X POST "<logic-app-trigger-url>" \
  -H "Content-Type: application/json" \
  -d '{"storageAccountResourceId": "<storage-account-resource-id>"}'
```

---

## Deliberate Misconfigurations

Created to generate Defender findings for the demo:

| # | Resource | Misconfiguration | Defender Finding |
|---|----------|-----------------|-----------------|
| 1 | `stsecopsmooz27g5` | `allowBlobPublicAccess = true` | **Auto-remediated by Logic App** |
| 2 | `stsecopsmooz27g5` | `httpsTrafficOnly = false` | Flagged — secure transfer disabled |

---

## Security Design Decisions

**Why Managed Identity instead of Service Principal?**
No credentials to rotate, store, or leak. The Logic App's identity is granted only `Storage Account Contributor` on the resource group — least privilege. If the Logic App is compromised, the blast radius is limited to storage accounts in that RG.

**Why Consumption-tier Logic App?**
Pay-per-execution. For a remediation playbook that fires on incidents, the cost is fractions of a cent per run. Standard tier has a fixed monthly cost that isn't justified for low-frequency automation.

**Why Terraform over Bicep?**
Terraform is provider-agnostic and dominant in the job market. The modules written here are reusable for follow-on projects and pluggable into a GitHub Actions OIDC pipeline. Bicep would have been slightly tighter Azure integration but only matters in Microsoft-only shops.

**Why uaenorth?**
Closest low-cost Azure region. Note: UAE North has limited Logic App connector availability — the Microsoft Sentinel incident connector is not available in this region. In production, deploy to `westeurope` or `eastus` where the full connector catalog is available. The remediation pipeline itself works identically regardless of region.

---

## What I'd Do at Production Scale

- **Multi-subscription coverage:** Defender for Cloud management group policy + Continuous Export at management group level — one pipeline covers all subscriptions
- **Sentinel incident trigger:** Replace HTTP trigger with the Microsoft Sentinel incident connector trigger for fully automated incident-driven remediation (requires deploying to a region with full connector support)
- **GitHub Actions OIDC:** Replace `az login` with federated identity — no secrets in CI/CD. Terraform backend in Azure Storage with state locking
- **Additional remediation playbooks:** NSG rules open to 0.0.0.0/0, missing disk encryption, SQL auditing disabled — same pattern, different ARM calls
- **Suppression rules:** Prevent duplicate incidents when a finding fires multiple times before remediation completes
- **Private endpoints on LAW:** Ensure log data never traverses the public internet
- **Alert fatigue management:** Sentinel fusion rules + entity behavior analytics to correlate findings into meaningful incidents rather than one incident per recommendation

---

## Results

| Metric | Value |
|--------|-------|
| Time to detect misconfiguration | ~5 minutes (Defender scan cycle) |
| Time to remediate after detection | < 30 seconds |
| End-to-end time | < 60 seconds |
| Human involvement | Zero (for known-safe remediations) |
| Credentials stored | None (Managed Identity) |

---

## Build Log

See [BUILD_LOG.md](BUILD_LOG.md) for session-by-session notes, errors encountered, and decisions made.
