#Example1:
locals {
  current_time = timestamp()
  current_date = formatdate("YYYY-MM-DD",local.current_time)
}
output "date-time" {
  value = {
    current_time = local.current_time
    todaydate = local.current_date
  }
}
#Example 2: create New Resource group with timestamp tag
resource "azurerm_resource_group" "rg1" {
  name = "testing-rg"
  location = "westus"
  tags = {
    created_date = local.current_time
  }
}