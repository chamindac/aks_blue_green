resource "random_password" "sql_password" {
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

resource "azurerm_mssql_server" "demo" {
  name                         = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-sqlsvr"
  resource_group_name          = azurerm_resource_group.instancerg.name
  location                     = azurerm_resource_group.instancerg.location
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_password.result
  version                      = "12.0"

  tags = merge(tomap({
    Service = "sql_server",
  }), local.tags)
}

resource "azurerm_mssql_firewall_rule" "demo_allow_azure" {
  name             = "AzureServices"
  server_id        = azurerm_mssql_server.demo.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "demo_dev" {
  name             = "DevIp"
  server_id        = azurerm_mssql_server.demo.id
  start_ip_address = var.DEVIP
  end_ip_address   = var.DEVIP
}

resource "azurerm_mssql_firewall_rule" "demo_dev2" {
  name             = "DevIp2"
  server_id        = azurerm_mssql_server.demo.id
  start_ip_address = "193.91.207.187"
  end_ip_address   = "193.91.207.187"
}

resource "azurerm_mssql_virtual_network_rule" "demo_aks" {
  name      = "sql-aks"
  server_id = azurerm_mssql_server.demo.id
  subnet_id = azurerm_subnet.aks.id
}

resource "azurerm_mssql_database" "demo" {
  name           = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-sqldb"
  server_id      = azurerm_mssql_server.demo.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "Basic"
  zone_redundant = false

  tags = merge(tomap({
    Service = "sql_db",
  }), local.tags)
}