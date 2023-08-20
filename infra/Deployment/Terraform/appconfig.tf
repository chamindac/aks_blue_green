data "azurerm_client_config" "current" {}

resource "azurerm_app_configuration" "appconf" {
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-appconfig-ac"
  resource_group_name = azurerm_resource_group.instancerg.name
  location            = azurerm_resource_group.instancerg.location
  sku                 = "standard"
}

resource "azurerm_role_assignment" "appconf_dataowner" {
  scope                = azurerm_app_configuration.appconf.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_app_configuration_key" "config_kv" {
  for_each = {
    "SQLServerName"   = azurerm_mssql_server.demo.name
    "SQLDatabaseName" = azurerm_mssql_database.demo.name
    # need below as shared - set always the live value
    "DemoCustomer" = "Endpoint=http://customer-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "kv" # key value
  label                  = azurerm_resource_group.instancerg.name
  value                  = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner
  ]
}

resource "azurerm_app_configuration_key" "config_kv_blue" {
  for_each = {
    "DemoCustomer" = "Endpoint=http://customer-api.${local.aks_dns_prefix_blue}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
    "DemoInvoice"  = "Endpoint=http://invoice-api.${local.aks_dns_prefix_blue}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
    "DemoOrder"    = "Endpoint=http://order-api.${local.aks_dns_prefix_blue}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
    "DemoPayment"  = "Endpoint=http://payment-api.${local.aks_dns_prefix_blue}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "kv" # key value
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_blue}"
  value                  = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner
  ]
}

resource "azurerm_app_configuration_key" "config_kv_green" {
  for_each = {
    "DemoCustomer" = "Endpoint=http://customer-api.${local.aks_dns_prefix_green}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
    "DemoInvoice"  = "Endpoint=http://invoice-api.${local.aks_dns_prefix_green}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
    "DemoOrder"    = "Endpoint=http://order-api.${local.aks_dns_prefix_green}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
    "DemoPayment"  = "Endpoint=http://payment-api.${local.aks_dns_prefix_green}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net/"
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "kv" # key value
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_green}"
  value                  = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner
  ]
}

resource "azurerm_app_configuration_key" "config_vault" {
  for_each = {
    "DemoSecret"      = azurerm_key_vault_secret.secret["DemoSecret"].versionless_id
    "SqlDBConnection" = azurerm_key_vault_secret.secret["SqlDBConnection"].versionless_id
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "vault" # keyvault reference
  label                  = azurerm_resource_group.instancerg.name
  vault_key_reference    = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner
  ]
}

resource "azurerm_app_configuration_key" "config_vault_blue" {
  for_each = {
    "AzureWebJobsStorage" = azurerm_key_vault_secret.secret["AzureWebJobsStorage-blue"].versionless_id
    "EventHubConsumer1"   = azurerm_key_vault_secret.secret["EventHubConsumer-1-blue"].versionless_id
    "EventHubConsumer2"   = azurerm_key_vault_secret.secret["EventHubConsumer-2-blue"].versionless_id
    "EventHubPublisher1"  = azurerm_key_vault_secret.secret["EventHubPublisher-1-blue"].versionless_id
    "EventHubPublisher2"  = azurerm_key_vault_secret.secret["EventHubPublisher-2-blue"].versionless_id
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "vault" # keyvault reference
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_blue}"
  vault_key_reference    = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner
  ]
}

resource "azurerm_app_configuration_key" "config_vault_green" {
  for_each = {
    "AzureWebJobsStorage" = azurerm_key_vault_secret.secret["AzureWebJobsStorage-green"].versionless_id
    "EventHubConsumer1"   = azurerm_key_vault_secret.secret["EventHubConsumer-1-green"].versionless_id
    "EventHubConsumer2"   = azurerm_key_vault_secret.secret["EventHubConsumer-2-green"].versionless_id
    "EventHubPublisher1"  = azurerm_key_vault_secret.secret["EventHubPublisher-1-green"].versionless_id
    "EventHubPublisher2"  = azurerm_key_vault_secret.secret["EventHubPublisher-2-green"].versionless_id
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "vault" # keyvault reference
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_green}"
  vault_key_reference    = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner
  ]
}