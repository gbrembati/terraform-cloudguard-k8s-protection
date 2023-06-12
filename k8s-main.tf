
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
          resources {
            requests = {
              cpu = "100m"
              memory = "160Mi"
            }
            limits = {
              cpu = "200m"
              memory = "256Mi"
            }
          }
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

resource "kubernetes_service" "unprotected-app-svc" {
  metadata {
    name      = "${var.app-name}-unprotected"
    namespace = kubernetes_namespace.app-namespace.id
  }
  spec {
    selector = {
      app = kubernetes_deployment.app-deployment.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress_v1" "appsec-ext-ingress" {
  wait_for_load_balancer = true
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
  depends_on = [helm_release.ckp-appsec,kubernetes_service.app-svc]
}

output "juiceshop-protected-fqdn" {
  description = "The FQDN of the JuiceShop app protected by Appsec"
  value = "http://juiceshop-protected.${azurerm_dns_zone.mydns-public-zone.name}"
}

output "juiceshop-unprotected-fqdn" {
  description = "The FQDN of the JuiceShop app exposed direcly"
  value = "http://juiceshop-unprotected.${azurerm_dns_zone.mydns-public-zone.name}"
}
