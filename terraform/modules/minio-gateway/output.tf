output "access_key" {
  description = "access key"
  value       = data.kubernetes_secret.minio["root-user"]
  sensitive   = true
}

output "secret_key" {
  description = "Storage account access key."
  value       = data.kubernetes_secret.minio["root-password"]
  sensitive   = true
}

output "endpoint" {
  description = "FQDN for the MinIO endpoint"
  value       = "http://minio-gateway.${var.namespace}.svc.cluster.local:9000"
  sensitive   = true
}

