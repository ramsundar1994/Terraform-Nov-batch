variable "resource_group" {
  type    = list(string)
  default = ["rg-dev", "rg-test", "rg-prod"]
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "vm_size" {
  type = map(string)
  default = {
    "dev"  = "Standard_D2s_v3"
    "test" = "Standard_B2s"
    "prod" = "Standard_D2s_v3"
  }
}