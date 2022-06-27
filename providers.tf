terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.88.1"
    }
    dome9 = {
      source = "dome9/dome9"
      version = "1.25.3"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.11.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.5.1"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.1.0"
    }
    inext = {
      source = "CheckPointSW/infinity-next"
      version = "~> 1.1.0"
    }
  }
}

provider "azurerm" {
  features { }
  client_id       = var.azure-client-id
  client_secret   = var.azure-client-secret
  subscription_id = var.azure-subscription
  tenant_id       = var.azure-tenant
}

provider "dome9" {
  dome9_access_id   = var.cspm-key-id
  dome9_secret_key  = var.cspm-key-secret
  base_url          = var.cspm-api-endpoint
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.host
  username               = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.username
  password               = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.host
    username               = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.username
    password               = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config.0.cluster_ca_certificate)
  }
}

provider "inext" {
  region = "eu"
  client_id  = var.appsec-client-id
  access_key = var.appsec-client-secret
}