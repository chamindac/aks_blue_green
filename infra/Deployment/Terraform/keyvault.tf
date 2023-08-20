# This alone does not work for destroy KV. Need pipeline to set and remove agent if KV is deleted. Add pipeline IP steps to TF apply if KV need to be destroyed via TF and to ensure build agent IP removed from KV after use for deployment.
# Secrets update and delete works in second attempt as plan and apply happen in same build agent in 2 and 3 attempts.
# Get IP of build agent (Hosted agent IP is dynamic)
data "http" "mytfip" {
  url = "https://api.ipify.org" # http://ipv4.icanhazip.com
}

resource "azurerm_key_vault" "instancekeyvault" {
  name                        = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-kv"
  location                    = azurerm_resource_group.instancerg.location
  resource_group_name         = azurerm_resource_group.instancerg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_deployment      = false
  enabled_for_disk_encryption = false
  purge_protection_enabled    = false # allow purge for drop and create in demos. else this should be set to true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["193.91.207.187/32", "${var.DEVIP}/32", "${chomp(data.http.mytfip.response_body)}/32"]
    virtual_network_subnet_ids = [
      "${azurerm_subnet.aks.id}"
    ]
  }

  # Sub Owners
  access_policy {
    tenant_id          = var.TENANTID
    object_id          = data.azuread_group.sub_owners.object_id
    secret_permissions = ["Get", "List"]
  }

  # Infra Deployment Service Principal
  access_policy {
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    key_permissions         = ["Get", "Purge", "Recover"]
    secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
    certificate_permissions = ["Create", "Get", "Import", "List", "Update", "Delete", "Purge", "Recover"]
  }

  # Containers in AKS via SPN
  access_policy {
    tenant_id          = var.TENANTID
    object_id          = data.azuread_service_principal.akskv.object_id
    secret_permissions = ["Get", "List", ]
  }

  tags = merge(tomap({
    Service = "key_vault",
  }), local.tags)
}

# Secrets 
resource "azurerm_key_vault_secret" "secret" {
  for_each = {
    AzureWebJobsStorage-blue  = var.SYS_BLUE_DEPLOY ? "${module.eventhubs_blue[0].storage_connection_string}" : "${local.dummy_secret}"
    EventHubConsumer-1-blue   = var.SYS_BLUE_DEPLOY ? "${module.eventhubs_blue[0].consumer_1}" : "${local.dummy_secret}"
    EventHubPublisher-1-blue  = var.SYS_BLUE_DEPLOY ? "${module.eventhubs_blue[0].publisher_1}" : "${local.dummy_secret}"
    EventHubConsumer-2-blue   = var.SYS_BLUE_DEPLOY ? "${module.eventhubs_blue[0].consumer_2}" : "${local.dummy_secret}"
    EventHubPublisher-2-blue  = var.SYS_BLUE_DEPLOY ? "${module.eventhubs_blue[0].publisher_2}" : "${local.dummy_secret}"
    AzureWebJobsStorage-green = var.SYS_GREEN_DEPLOY ? "${module.eventhubs_green[0].storage_connection_string}" : "${local.dummy_secret}"
    EventHubConsumer-1-green  = var.SYS_GREEN_DEPLOY ? "${module.eventhubs_green[0].consumer_1}" : "${local.dummy_secret}"
    EventHubPublisher-1-green = var.SYS_GREEN_DEPLOY ? "${module.eventhubs_green[0].publisher_1}" : "${local.dummy_secret}"
    EventHubConsumer-2-green  = var.SYS_GREEN_DEPLOY ? "${module.eventhubs_green[0].consumer_2}" : "${local.dummy_secret}"
    EventHubPublisher-2-green = var.SYS_GREEN_DEPLOY ? "${module.eventhubs_green[0].publisher_2}" : "${local.dummy_secret}"
    DemoSecret                = "Notarealsecret"
    SqlDBConnection           = "Server=tcp:${azurerm_mssql_server.demo.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.demo.name};Persist Security Info=False;User ID=${azurerm_mssql_server.demo.administrator_login};Password=${azurerm_mssql_server.demo.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.instancekeyvault.id

  depends_on = [
    azurerm_key_vault.instancekeyvault
  ]
}