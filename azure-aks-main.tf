resource "azurerm_resource_group" "rg-dns-myzone" {
  name     = "rg-dns-myzone"
  location = var.location
}
resource "azurerm_dns_zone" "mydns-public-zone" {
  name                = var.mydns-zone
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
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

  tags = {
    owner       = local.tags.owner
    managed-by  = local.tags.managed-by
    tf-cloud-workspace  = local.tags.tf-cloud-workspace
    tf-cloud-workflow   = local.tags.tf-cloud-workflow
  }
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