resource "kubernetes_namespace" "app-namespace" {
  metadata {
    name = "${var.app-name}-ns"
  }
  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
}

resource "kubernetes_deployment" "app-deployment" {
  metadata {
    name      = var.app-name
    namespace = kubernetes_namespace.app-namespace.id
    labels = {
      app = var.app-name
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = var.app-name
      }
    }
    template {
      metadata {
        labels = {
          app = var.app-name
        }
      }
      spec {
        container {
          image = "bkimminich/juice-shop"
          name  = var.app-name
        }
      }
    }
  }
}

resource "kubernetes_service" "app-svc" {
  metadata {
    name      = var.app-name
    namespace = kubernetes_namespace.app-namespace.id
  }
  spec {
    selector = {
      app = kubernetes_deployment.app-deployment.metadata[0].labels.app
    }
    port {
      port        = 3000
      target_port = 3000
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "appsec-ingress" {
  metadata {
    name = "${var.app-name}-ingress"
    namespace = kubernetes_namespace.app-namespace.id
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "juiceshop-protected.${azurerm_dns_zone.mydns-public-zone.name}"
      http {
        path {
          path_type = "Prefix"
          path = "/"
          backend {
            service {
              name = kubernetes_service.app-svc.metadata.0.name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}

output "juiceshop-protected-fqdn" {
  description = "The FQDN of the JuiceShop app protected by Appsec"
  value = "http://juiceshop-protected.${azurerm_dns_zone.mydns-public-zone.name}"
}