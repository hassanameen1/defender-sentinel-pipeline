# Deliberate misconfigurations for Defender for Cloud detection demo.
# These are intentionally insecure — do not use these patterns in production.

resource "random_string" "storage_suffix" {
  length  = 8
  upper   = false
  special = false
}

# Misconfiguration 1: Public storage account
# Defender finding: "Storage account public access should be disallowed"
# Auto-remediated by the Logic App playbook
resource "azurerm_storage_account" "public_demo" {
  name                     = "stsecops${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.secops.name
  location                 = azurerm_resource_group.secops.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # DELIBERATE MISCONFIGURATION — this is what Defender detects
  allow_nested_items_to_be_public = true

  # DELIBERATE MISCONFIGURATION — secure transfer disabled
  https_traffic_only_enabled = false

  tags = merge(local.tags, {
    purpose = "misconfiguration-demo"
  })
}
