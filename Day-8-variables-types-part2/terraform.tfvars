resource_group = {
  location = "eastasia"
  name     = "object-RG"
}
resource_group_common = {
  "nonprod" = {
    name     = "Nonprod-RG"
    location = "westus"
  }
  "prod" = {
    name     = "Prod-RG"
    location = "eastus"
  }
}
# storage account creation
storage_account = {
  "nonprod" = {
    storage_account_name     = "stg0875675"
    location                 = "westus"
    resource_group_name      = "Nonprod-RG"
    account_replication_type = "LRS"
    account_tier             = "Standard"
  }
  "prod" = {
    storage_account_name     = "stg0875675235"
    location                 = "eastus"
    resource_group_name      = "Prod-RG"
    account_replication_type = "LRS"
    account_tier             = "Standard"
  }
}