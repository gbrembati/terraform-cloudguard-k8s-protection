resource "azurerm_resource_group" "rg-dns-myzone" {
  name     = "rg-dns-myzone"
  location = var.location
}
resource "azurerm_dns_zone" "mydns-public-zone" {
  name                = var.mydns-zone
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
}
resource "azurerm_dns_a_record" "juiceshop-dns-record" {
  name                = kubernetes_service.unprotected-app-svc.metadata.0.name
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  records             = ["${kubernetes_service.unprotected-app-svc.status.0.load_balancer.0.ingress.0.ip}"]
  depends_on = [kubernetes_service.unprotected-app-svc]
}
resource "azurerm_dns_a_record" "juiceshop-appsec-dns-record" {
  name                = "juiceshop-protected"
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  records             = ["${data.kubernetes_service.ckp-appsec-controller.status.0.load_balancer.0.ingress.0.ip}"]
  depends_on = [helm_release.ckp-appsec,data.kubernetes_service.ckp-appsec-controller]
}

resource "azurerm_resource_group" "rg-aks-cluster" {
  name     = "rg-${var.k8s-cluster-name}"
  location = var.location
}
resource "random_id" "log-workspace-suffix" {
  byte_length = 4
}
resource "azurerm_log_analytics_workspace" "log-workspace" {
  name                = "log-${var.k8s-cluster-name}-${random_id.log-workspace-suffix.dec}"
  location            = local.log-analytics-location
  resource_group_name = azurerm_resource_group.rg-aks-cluster.name
  sku                 = var.log-analytics-sku
}
resource "azurerm_log_analytics_solution" "log-analytics" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.log-workspace.location
  resource_group_name   = azurerm_log_analytics_workspace.log-workspace.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log-workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log-workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
    name                = var.k8s-cluster-name
    location            = azurerm_resource_group.rg-aks-cluster.location
    resource_group_name = azurerm_resource_group.rg-aks-cluster.name
    dns_prefix          = var.k8s-cluster-name
    
    default_node_pool {
      name            = "ckpnodepool"
      node_count      = var.node-pool-count
      vm_size         = "Standard_D2_v2"
    }
    node_resource_group = "${azurerm_resource_group.rg-aks-cluster.name}-nodepool"
    
    identity {
      type = "SystemAssigned"
    }
    
    addon_profile {
      oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.log-workspace.id
      }
    }

    network_profile {
      load_balancer_sku = "Standard"
      network_plugin    = "kubenet"
    }
}