variable "azure-client-id" {
    description = "Insert your application client-id"
    sensitive = true
    type = string
} 
variable "azure-client-secret" {
    description = "Insert your application client-secret"
    sensitive = true
    type = string
}
variable "azure-subscription" {
    description = "Insert your subscription-id"
    sensitive = true
    type = string
}
variable "azure-tenant" {
    description = "Insert your active-directory-id"
    sensitive = true
    type = string
}

variable "mydns-zone" {
    description = "Specify your dns zone"
    type = string
}
variable "k8s-cluster-name" {
    description = "the name of your AKS cluster"
    default = "aks-cloudguard"
    type = string
}
variable "node-pool-count" {
    default = 3
}
variable "location" {
    type = string
}
variable "log-analytics-location" {
    type = string
}

variable "log-analytics-sku" {
    default = "PerGB2018"
}