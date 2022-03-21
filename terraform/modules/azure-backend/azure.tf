resource "azurerm_resource_group" "s3proxy" {
  name     = "s3-proxy-resources"
  location = "Canada Central"
}

resource "azurerm_storage_account" "s3proxy" {
  name                     = "s3proxyresources"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  account_kind             = "StorageV2"
  # Use object versioning instead
  is_hns_enabled           = "false"
}

resource "azurerm_storage_container" "s3proxy" {
  name                  = "daaas"
  storage_account_name  = azurerm_storage_account.s3proxy.name
  container_access_type = "private"
}
