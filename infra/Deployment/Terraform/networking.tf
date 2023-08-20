# vnet
resource "azurerm_virtual_network" "env_vnet" {
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-vnet"
  resource_group_name = azurerm_resource_group.instancerg.name
  location            = azurerm_resource_group.instancerg.location
  address_space       = [var.VNET_CIDR]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-pip"
  location            = azurerm_resource_group.instancerg.location
  resource_group_name = azurerm_resource_group.instancerg.name
  domain_name_label   = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}"
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_tags             = {}
  tags                = {}
  zones = [
    "1",
    "2",
    "3"
  ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-nsg"
  location            = azurerm_resource_group.instancerg.location
  resource_group_name = azurerm_resource_group.instancerg.name

  tags = merge(tomap({
    Service = "network_security_group"
  }), local.tags)
}

## AKS Ingress AppGateway
resource "azurerm_subnet" "aks_agw" {
  name                 = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-aks-agw-snet"
  resource_group_name  = azurerm_virtual_network.env_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.env_vnet.name
  address_prefixes     = ["${var.SUBNET_CIDR_AKS_AGW}"]
}

# AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-aks-snet"
  resource_group_name  = azurerm_virtual_network.env_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.env_vnet.name
  address_prefixes     = ["${var.SUBNET_CIDR_AKS}"]
  service_endpoints = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureCosmosDB",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.ServiceBus",
    "Microsoft.Web"
  ]
}

# Associate AKS subnet with network security group
resource "azurerm_subnet_network_security_group_association" "aks_nsg" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

## AppGateway

resource "azurerm_subnet" "subnet_agw" {
  name                 = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-agw-snet"
  resource_group_name  = azurerm_virtual_network.env_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.env_vnet.name
  address_prefixes     = ["${var.SUBNET_CIDR_AGW}"]
  service_endpoints    = ["Microsoft.Web", "Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg_agw" {
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-agw-nsg"
  location            = azurerm_resource_group.instancerg.location
  resource_group_name = azurerm_resource_group.instancerg.name

  security_rule {
    name                       = "AGW"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(tomap({
    Service = "network_security_group"
  }), local.tags)
}

resource "azurerm_subnet_network_security_group_association" "nsgass_agw" {
  subnet_id                 = azurerm_subnet.subnet_agw.id
  network_security_group_id = azurerm_network_security_group.nsg_agw.id
}

resource "azurerm_application_gateway" "appgateway" {
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-agw"
  location            = azurerm_resource_group.instancerg.location
  resource_group_name = azurerm_resource_group.instancerg.name

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 10
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.subnet_agw.id

  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "DemoPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  #region backend_address_pools
  backend_address_pool {
    fqdns = ["invoice-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"]
    name  = "IngressAKS"
  }

  #endregion backend_address_pools

  #region backend_http_settings

  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = "IngressAKS"
    port                  = 80
    probe_name            = "IngressAKS"
    protocol              = "Http"
    request_timeout       = 30
  }

  #endregion backend_http_settings

  #region http listener

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "DemoPublicFrontendIp"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  #endregion http listener

  #region Request routing rule

  request_routing_rule {
    http_listener_name = "http"
    name               = "RequestRouting"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "RequestRouting"
    priority           = 10
  }

  #endregion Request routing rule

  #region Probe
  probe {
    host                = "invoice-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
    interval            = 30
    name                = "IngressAKS"
    path                = "/api/health"
    protocol            = "Http"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399", ]
      body        = ""
    }
  }

  #endregion Probe

  #region Url path map

  url_path_map {
    default_backend_address_pool_name  = "IngressAKS"
    default_backend_http_settings_name = "IngressAKS"
    name                               = "RequestRouting"

    path_rule {
      backend_address_pool_name  = "IngressAKS"
      backend_http_settings_name = "IngressAKS"
      name                       = "IngressAKS"
      rewrite_rule_set_name      = "IngressAKS"
      paths                      = ["/*", ]
    }
  }

  #endregion Url path map


  #region Rewrite rule set

  rewrite_rule_set {
    name = "IngressAKS"

    # Customer
    rewrite_rule {
      name          = "CustomerAPIHealth"
      rule_sequence = 100
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetCustomerHealth.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "customer-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/health"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "CustomerAPIForecastCount"
      rule_sequence = 101
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetCustomerForecastCount.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "customer-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecastcount"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "CustomerAPIForecast"
      rule_sequence = 102
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetCustomerForecast.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "customer-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecast"
        reroute = false
      }
    }

    # Invoice
    rewrite_rule {
      name          = "InvoiceAPIHealth"
      rule_sequence = 200
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetInvoiceHealth.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "invoice-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/health"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "InvoiceAPIForecastCount.chq"
      rule_sequence = 201
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetInvoiceForecastCount"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "invoice-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecastcount"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "InvoiceAPIForecast.chq"
      rule_sequence = 202
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetInvoiceForecast"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "invoice-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecast"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "InvoiceAPINewInvoice"
      rule_sequence = 203
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/NewInvoice.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "invoice-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/newinvoice"
        reroute = false
      }
    }

    # Order
    rewrite_rule {
      name          = "OrderAPIHealth"
      rule_sequence = 300
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetOrderHealth.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "order-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/health"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "OrderAPIForecastCount"
      rule_sequence = 301
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetOrderForecastCount.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "order-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecastcount"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "OrderAPIForecast"
      rule_sequence = 302
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetOrderForecast.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "order-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecast"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "OrderAPINewOrder"
      rule_sequence = 303
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/NewOrder.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "order-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/neworder"
        reroute = false
      }
    }

    # Payment
    rewrite_rule {
      name          = "PaymentAPIHealth"
      rule_sequence = 400
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetPaymentHealth.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "payment-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/health"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "PaymentAPIForecastCount"
      rule_sequence = 401
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetPaymentForecastCount.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "payment-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecastcount"
        reroute = false
      }
    }
    rewrite_rule {
      name          = "PaymentAPIForecast"
      rule_sequence = 402
      condition {
        variable    = "var_uri_path"
        pattern     = "/ch/demo/1.0/GetPaymentForecast.chq"
        ignore_case = true
      }
      request_header_configuration {
        header_name  = "Host"
        header_value = "payment-api.${local.aks_dns_prefix_live}.${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}.net"
      }
      url {
        path    = "/api/forecast"
        reroute = false
      }
    }

  }
  #endregion Rewrite rule set

}