variable "project" {
    type =string
    default = "prod"
}
variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "subnetbit" {
    default = 2
}