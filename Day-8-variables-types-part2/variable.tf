variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "testing-rg"
    location = "westus"
  }
}
variable "resource_group_common" {
  type = map(object({
    name     = string
    location = string
  }))
  default = {
    "nonprod" = {
      name     = "nonprod-rg"
      location = "westus"
    }
    "prod" = {
      name     = "prod-rg"
      location = "eastasia"
    }
  }
}

#storage account variable
variable "storage_account" {
  type = map(object({
    storage_account_name     = string
    location                 = string
    resource_group_name      = string
    account_replication_type = string
    account_tier             = string
  }))
}