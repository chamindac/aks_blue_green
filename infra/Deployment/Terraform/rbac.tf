# refer to sub_owners ad group to assign as aks admins 
data "azuread_group" "sub_owners" {
  display_name     = "sub_owners"
  security_enabled = true
}

# aks kv app
data "azuread_application" "akskv" {
  display_name = "${var.PREFIX}-${var.PROJECT}-aks-kv-app"
}

data "azuread_service_principal" "akskv" {
  application_id = data.azuread_application.akskv.application_id
}