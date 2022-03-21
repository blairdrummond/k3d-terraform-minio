resource "kubernetes_namespace" "minio" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "minio" {
  name       = "minio-gateway"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "minio"
  version    = "10.1.12"
  values = [
    "${file("minio-gateway.yaml")}"
  ]
  #set {
  #  name  = "service.type"
  #  value = "ClusterIP"
  #}
  depends_on = [
    kubernetes_namespace.minio
  ]
}

data "kubernetes_secret" "minio" {
  metadata {
    name      = "minio"
    namespace = var.namespace
  }
  depends_on = [
    helm_release.minio
  ]
}
