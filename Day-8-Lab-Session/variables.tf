#variable type (Objects)
variable "resource_group" {
  type = object({
    resource_group_name = string
    location            = string
  })
}
variable "vnet" {
  type = object({
    name          = string
    address_space = list(string)
  })
}
variable "subnet" {
  type = object({
    name             = string
    address_prefixes = list(string)
  })
}
variable "nic" {
  type = list(string)
}
variable "vm" {
  type = object({
    name           = string
    size           = string
    admin_username = string
    admin_password = string
  })
}
variable "osdisk" {
  type = string
}
variable "source_image" {
  type = object({
    offer     = string
    sku       = string
    publisher = string
    version   = string
  })
}
variable "tags" {
  type = map(string)
  default = {
    "env" = "testing"
    "owner" = "abz"
    "apps"  = "windowsapp"
  }
}