variable "resourcegroup" {
  type = string
  default = ""
}
variable "location" {
  type = string
}
variable "vnet-name" {
  type = string
}
variable "address_space" {
  
}
variable "subnet_name" {
  type = string
}
variable "address_prefixes" {
  
}
variable "vm_config" {
  type = map(object({
    vmsize = string
    admin_username = string
    admin_password = string
    image-sku = string
    nic_count = number
  }))
}