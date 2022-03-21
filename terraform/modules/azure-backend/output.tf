output "name" {
  value       = azurerm_storage_account.s3proxy.name
  description = "Storage account name."
}

output "access_key" {
  value       = azurerm_storage_account.s3proxy.secondary_access_key
  description = "Storage account access key."
  sensitive   = true
}

