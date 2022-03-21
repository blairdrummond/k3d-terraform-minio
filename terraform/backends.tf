resource "azurerm_resource_group" "s3proxy" {
  name     = "s3-resources"
  location = "Canada Central"
}

module "storage_account" {
  source = "./modules/azure-backend/"

  resource_group = azurerm_resource_group.s3proxy.name
  location       = azurerm_resource_group.s3proxy.location
}


module "minio" {
  source    = "./modules/minio"
  namespace = "minio"
}


module "s3proxy" {
  source = "./modules/s3proxy"

  namespace      = "s3proxy"
  storageaccount = module.storage_account.name
  storagekey     = module.storage_account.access_key
}


module "minio_gateway" {
  source    = "./modules/minio"
  namespace = "minio-gateway"
}


resource "kubernetes_service" "external_aws_js_s3_explorer" {
  metadata {
    name = "aws-js-s3-explorer"
    namespace = "s3proxy"
  }

  spec {
    type = "ExternalName"
    external_name = "nginx.aws-js-s3-explorer.svc.cluster.local"
  }
}

resource "kubernetes_ingress" "s3proxy" {
  metadata {
    name = "s3proxy"
    namespace = "s3proxy"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }

  spec {
    backend {
      service_name = "s3proxy"
      service_port = 9000
    }

    rule {
      host = "s3proxy.cloud.local"
      http {
        path {
          backend {
            service_name = "s3proxy"
            service_port = 9000
          }

          path = "/"
        }


        path {
          backend {
            service_name = "aws-js-s3-explorer"
            service_port = 80
          }

          path = "/index.html"
        }


        path {
          backend {
            service_name = "aws-js-s3-explorer"
            service_port = 80
          }

          path = "/explorer.css"
        }


        path {
          backend {
            service_name = "aws-js-s3-explorer"
            service_port = 80
          }

          path = "/explorer.js"
        }


      }
    }

    #tls {
    #  secret_name = "tls-secret"
    #}
  }
}
