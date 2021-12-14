variable "cspm-key-id" {
    description = "Insert your API Key ID"
    type = string
    sensitive = true
}
variable "cspm-key-secret" {
    description = "Insert your API Key Secret"
    type = string
    sensitive = true
}
variable "cspm-org-unit" {
    description = "Insert the name of your Organizational Unit"
    type = string
}
variable "cspm-residency" {
    description = "Where is your CSPM platform instanced? usea1 [default], euwe1, apso1"
    type = string
    default = "usea1"
}
variable "cspm-mail" {
    description = "The email you want the CSPM to send reports to"
    type = string  
}