variable "azure-client-id" {
    description = "Insert your application client-id"
    sensitive = true
} 
variable "azure-client-secret" {
    description = "Insert your application client-secret"
    sensitive = true
}
variable "azure-subscription" {
    description = "Insert your subscription-id"
    sensitive = true
}
variable "azure-tenant" {
    description = "Insert your active-directory-id"
    sensitive = true
}

variable "mydns-zone" {
    description = "Specify your dns zone"
}
variable "k8s-cluster-name" {
    description = "the name of your AKS cluster"
    default = "aks-cloudguard"
}
variable "node-pool-count" {
    default = 3
}
variable "log-analytics-sku" {
    default = "PerGB2018"
}