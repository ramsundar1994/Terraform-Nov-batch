#read subscription details
data "azurerm_subscription" "subscription" {

}
#create App Registeration
resource "azuread_application" "app" {
  display_name = "terraform-spn-test"
}
# app secrets
resource "azuread_application_password" "app-secret" {
  display_name = "app-secret"
  application_id = azuread_application.app.id
}
#service principal
resource "azuread_service_principal" "spn" {
  client_id = azuread_application.app.client_id
}

# create password for service principal (SPN Secrets)
resource "azuread_service_principal_password" "spn-psd" {
  display_name = "spn-secret"
  service_principal_id = azuread_service_principal.spn.id
  end_date             = "2026-01-15T15:04:05Z" #1year
}
# Assign role to Service principal 
resource "azurerm_role_assignment" "role-assign" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.spn.object_id
}
output "spn-Secrets" {
  value = azuread_service_principal_password.spn-psd.value
  sensitive = true
}