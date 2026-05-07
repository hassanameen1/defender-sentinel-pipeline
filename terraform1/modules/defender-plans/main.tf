resource "azurerm_security_center_subscription_pricing" "cspm" {
  tier          = "Standard"
  resource_type = "CloudPosture"

}
resource "azurerm_security_center_subscription_pricing" "vms" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"

}
resource "azurerm_security_center_subscription_pricing" "storage-acc" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"
}
resource "azurerm_security_center_subscription_pricing" "keyVaults" {
  tier          = "Standard"
  resource_type = "KeyVaults"
  subplan       = "PerKeyVault"
}
resource "azurerm_security_center_subscription_pricing" "sqlServers" {
  tier          = "Standard"
  resource_type = "SqlServers"
}
