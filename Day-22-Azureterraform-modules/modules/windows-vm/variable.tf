variable "vmname" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "nic_count" {
  type = any 
}
variable "location" {
  type = string
}
variable "vmsize" {
  type = string
}
variable "admin_username" {
  type = string
}
variable "admin_password" {
  type = string
}
variable "image-sku" {
  type = string
}