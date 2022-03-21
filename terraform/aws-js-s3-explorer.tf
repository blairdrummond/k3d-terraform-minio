resource "kubernetes_namespace" "aws_js_s3_explorer" {
  metadata {
    name = "aws-js-s3-explorer"
  }
}

resource "kubernetes_deployment" "aws_js_s3_explorer" {
  metadata {
    name      = "nginx"
    namespace = "aws-js-s3-explorer"
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "aws-js-s3-explorer"
      }
    }
    template {
      metadata {
        labels = {
          app = "aws-js-s3-explorer"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "nginx-content"
            mount_path = "/usr/share/nginx/html"
            read_only  = "true"
          }
          #volume_mount {
          #  name       = "nginx-conf"
          #  mount_path = "/etc/nginx/nginx.conf"
          #  sub_path   = "nginx.conf" 
          #  read_only  = "true"
          #}
        }

        #volume {
        #  name = "nginx-conf"
        #  config_map {
        #    name = "nginx-conf"
        #  }
        #}

        volume {
          name = "nginx-content"
          config_map {
            name = "aws-js-s3-explorer"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "aws_js_s3_explorer" {
  metadata {
    name      = "nginx"
    namespace = "aws-js-s3-explorer"
  }
  spec {
    selector = {
      app = kubernetes_deployment.aws_js_s3_explorer.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}


data "http" "s3_explorer_index" {
  for_each = toset(["index.html", "explorer.css", "explorer.js"])
  url = "https://raw.githubusercontent.com/blairdrummond/aws-js-s3-explorer/v2-alpha/${each.key}"
}

# Do this from a taskfile instead.
resource "kubernetes_config_map" "example" {
  metadata {
    name      = "aws-js-s3-explorer"
    namespace = "aws-js-s3-explorer"
  }

  data = {
    "index.html"   = data.http.s3_explorer_index["index.html"].body
    "explorer.js"  = data.http.s3_explorer_index["explorer.js"].body
    "explorer.css" = data.http.s3_explorer_index["explorer.css"].body
  }
}


# # Do this from a taskfile instead.
# resource "kubernetes_config_map" "nginx_conf" {
#   metadata {
#     name      = "nginx-conf"
#     namespace = "aws-js-s3-explorer"
#   }
# 
#   data = {
#     "nginx.conf" = file("nginx.conf")
#   }
# }



