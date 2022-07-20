resource "azurerm_network_security_group" "allow-any" {
  name                = "permit-all_nsg"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location
  security_rule {
    name                       = "Allow_any"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow outbound"
    priority                   = 4090
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "c8000v" {
  name                = "c8000v-dmvpn_nsg"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location
  security_rule {
    name                       = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["64.104.0.0/16"]
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow_any"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow outbound"
    priority                   = 4090
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Deny_all"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                    = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}