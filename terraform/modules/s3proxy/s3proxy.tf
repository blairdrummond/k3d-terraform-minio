resource "kubernetes_namespace" "s3proxy" {
  metadata {
    name = var.namespace
  }
}


resource "kubernetes_secret" "storage_account" {
  metadata {
    name      = "s3proxy-config"
    namespace = var.namespace
  }

  data = {
    "LOG_LEVEL" = "info"

    # "S3PROXY_IDENTITY" = "local-identity"
    # "S3PROXY_CREDENTIAL" = "local-credential"

    "S3PROXY_AUTHORIZATION"          = "none"
    "S3PROXY_ENDPOINT"               = "http://0.0.0.0:80"
    "S3PROXY_VIRTUALHOST"            = ""
    "S3PROXY_CORS_ALLOW_ALL"         = "true"
    "S3PROXY_CORS_ALLOW_ORIGINS"     = ""
    "S3PROXY_CORS_ALLOW_METHODS"     = ""
    "S3PROXY_CORS_ALLOW_HEADERS"     = ""
    "S3PROXY_IGNORE_UNKNOWN_HEADERS" = "false"

    "JCLOUDS_PROVIDER" = "azureblob"
    "JCLOUDS_REGION"   = ""
    "JCLOUDS_REGIONS"  = "us-east-1"

    # Storage Account Name
    "JCLOUDS_IDENTITY" = var.storageaccount
    "JCLOUDS_ENDPOINT" = "https://${var.storageaccount}.blob.core.windows.net"

    # Storage Account Key
    "JCLOUDS_CREDENTIAL" = var.storagekey
  }
}



resource "kubernetes_service" "s3proxy_service" {
  metadata {
    name      = "s3proxy"
    namespace = var.namespace
    labels = {
      app = "s3proxy"
    }
  }
  spec {
    selector = {
      app = "s3proxy"
    }
    port {
      name        = "http"
      port        = 9000
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.s3proxy
  ]
}


resource "kubernetes_deployment" "s3proxy" {
  metadata {
    name      = "s3proxy"
    namespace = var.namespace
    labels = {
      app = "s3proxy"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "s3proxy"
      }
    }

    template {
      metadata {
        name = "s3proxy"
        labels = {
          app = "s3proxy"
        }
      }

      spec {

        container {
          image = "docker.io/andrewgaul/s3proxy:sha-05a39cf"
          name  = "s3proxy"

          env_from {
            secret_ref {
              name = "s3proxy-config"
            }
          }

          port {
            container_port = "80"
            name           = "http"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.s3proxy,
    kubernetes_secret.storage_account
  ]
}
