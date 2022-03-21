output "access_key" {
  value       = "local-identity"
  description = "S3 Access Key"
  sensitive   = true
}

output "secret_key" {
  value       = "local-credential"
  description = "S3 Secret Key"
  sensitive   = true
}

output "endpoint" {
  value       = "http://s3proxy.${var.namespace}.svc.cluster.local:9000"
  description = "The S3 Endpoint"
}
