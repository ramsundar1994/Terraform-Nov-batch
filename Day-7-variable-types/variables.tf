variable "rg-name" {
  type = string
  description = "this is for RG"
  default = "simple-rg"
}
variable "location" {
  type = string
  default = "westus"
}
# Example 1: Lists
variable "rg-names" {
  type = list(string)
  default = [ "rg-001" , "rg-02" , "rg-03" ]
}
#Exmple 2 : lists using locations
variable "location-list" {
  type = list(string)
  default = [ "" ]
}
# Eample 1: variable types (map)
variable "resource-groups" {
  type = map(string)
  default = {
    "map-rg" = "westus"
    "map-rg2" = "centralus"
  }
}