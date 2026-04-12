# Build Log

## 2026-04-12 — Session 1: Environment Setup

- Installed Homebrew and Azure CLI (v2.85.0) via Homebrew
- Installed Terraform 1.5.7 via Homebrew
- Authenticated to Azure via device code login (subscription: Azure subscription 1)
- Confirmed subscription ID: 36221517-0c68-45b1-b5f4-9a343303aa39, region: uaenorth
- Scaffolded full repo structure: terraform/, kql/, logic-apps/, screenshots/, linkedin/, architecture/
- Created terraform/versions.tf, variables.tf, outputs.tf, main.tf, terraform.tfvars.example
- Confirmed decisions: Teams for notifications, uaenorth region, naming convention: `<resource>-secops-prod`

**Next session starts with:** `terraform init` and `terraform apply` to create `rg-secops-prod`, then enable Defender for Cloud plans in the portal.
