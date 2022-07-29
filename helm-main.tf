resource "helm_release" "asset-mgmt" {
  name       = "cloudguard-cspm"
  repository = "https://raw.githubusercontent.com/CheckPointSW/charts/master/repository/"
  chart      = "cloudguard"
  namespace  = "cloudguard-cspm"
  create_namespace = true

  set {
    name  = "clusterID"
    value = "${dome9_cloudaccount_kubernetes.cspm-cluster.id}"
  }
  set {
    name  = "credentials.user"
    value = "${var.cspm-key-id}"
  }
  set {
    name  = "credentials.secret"
    value = "${var.cspm-key-secret}"
  }
  set {
    name  = "datacenter"
    value = "${var.cspm-residency}"
  }
  set {
    name = "addons.imageScan.enabled"
    value= "true"
  }
  set {
    name = "addons.admissionControl.enabled"
    value= "true"
  }
  depends_on = [dome9_cloudaccount_kubernetes.cspm-cluster,azurerm_kubernetes_cluster.aks-cluster]
}

resource "helm_release" "ckp-appsec" {
  name       = "cloudguard-appsec"
  chart      = "https://github.com/CheckPointSW/Infinity-Next/raw/main/deployments/cp-k8s-appsec-nginx-ingress-4.1.4.tgz"
  namespace  = "cloudguard-appsec"
  create_namespace = true

  set {
    name  = "appsec.agentToken"
    value = "${inext_kubernetes_profile.appsec-k8s-profile.authentication_token}"
  }
  set {
    name = "appsec.persistence.storageClass"
    value= "default"
  }
  set {
    name = "controller.ingressClassResource.name"
    value= "nginx"
  }
  depends_on = [azurerm_kubernetes_cluster.aks-cluster,inext_kubernetes_profile.appsec-k8s-profile]
}

data "kubernetes_service" "ckp-appsec-controller" {
  metadata {
    name = "${helm_release.ckp-appsec.name}-cp-k8s-appsec-nginx-ingress-controller"
    namespace = helm_release.ckp-appsec.namespace
  }
  depends_on = [helm_release.ckp-appsec]
}
