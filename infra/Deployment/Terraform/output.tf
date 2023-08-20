output "live_aks_name" {
  value = var.SYS_GREEN_IS_LIVE ? (
    var.SYS_GREEN_DEPLOY ? module.aks_green[0].aks_cluster_name : "No live cluster"
    ) : (
    module.aks_blue[0].aks_cluster_name
  )
}

output "app_deploy_aks_name" {
  value = var.SYS_GREEN_IS_LIVE ? (
    var.SYS_DEPLOYMENT_PHASE == "deploy" ? (
      var.SYS_BLUE_DEPLOY ? module.aks_blue[0].aks_cluster_name : module.aks_green[0].aks_cluster_name
      ) : (
      module.aks_green[0].aks_cluster_name
    )
    ) : (
    var.SYS_DEPLOYMENT_PHASE == "deploy" ? (
      var.SYS_GREEN_DEPLOY ? module.aks_green[0].aks_cluster_name : module.aks_blue[0].aks_cluster_name
      ) : (
      module.aks_blue[0].aks_cluster_name
    )
  )
}

output "app_deploy_dns_zone" {
  value = trimsuffix(replace((var.SYS_GREEN_IS_LIVE ? (
    var.SYS_DEPLOYMENT_PHASE == "deploy" ? (
      var.SYS_BLUE_DEPLOY ? azurerm_private_dns_a_record.aks_agw_blue.fqdn : azurerm_private_dns_a_record.aks_agw_green.fqdn
      ) : (
      azurerm_private_dns_a_record.aks_agw_green.fqdn
    )
    ) : (
    var.SYS_DEPLOYMENT_PHASE == "deploy" ? (
      var.SYS_GREEN_DEPLOY ? azurerm_private_dns_a_record.aks_agw_green.fqdn : azurerm_private_dns_a_record.aks_agw_blue.fqdn
      ) : (
      azurerm_private_dns_a_record.aks_agw_blue.fqdn
    )
  )), "*", ""), ".")
}

output "blue_green_app_config_label" {
  value = var.SYS_GREEN_IS_LIVE ? (
    var.SYS_DEPLOYMENT_PHASE == "deploy" ? (
      var.SYS_BLUE_DEPLOY ? azurerm_app_configuration_key.config_vault_blue["AzureWebJobsStorage"].label : azurerm_app_configuration_key.config_vault_green["AzureWebJobsStorage"].label
      ) : (
      azurerm_app_configuration_key.config_vault_green["AzureWebJobsStorage"].label
    )
    ) : (
    var.SYS_DEPLOYMENT_PHASE == "deploy" ? (
      var.SYS_GREEN_DEPLOY ? azurerm_app_configuration_key.config_vault_green["AzureWebJobsStorage"].label : azurerm_app_configuration_key.config_vault_blue["AzureWebJobsStorage"].label
      ) : (
      azurerm_app_configuration_key.config_vault_blue["AzureWebJobsStorage"].label
    )
  )
}

output "sql_connection" {
  value     = "Server=tcp:${azurerm_mssql_server.demo.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.demo.name};Persist Security Info=False;User ID=${azurerm_mssql_server.demo.administrator_login};Password=${azurerm_mssql_server.demo.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive = true
}

output "appconfig_connection" {
  value     = azurerm_app_configuration.appconf.secondary_read_key[0].connection_string
  sensitive = true
}