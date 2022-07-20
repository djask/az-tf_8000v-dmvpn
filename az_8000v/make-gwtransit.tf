resource "azurerm_public_ip" "vgw-pubip" {
  name                = "inside-vgw_pubip"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location
  allocation_method   = "Dynamic"
}

# Create a virtual network gateway and specify the bgp neighbor, keep default Azure ASNs for BGP
resource "azurerm_virtual_network_gateway" "net1-vgw" {
  name                = "c8000v-internal_vgw"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vgw-pubip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.internal-gw.id
  }
}

#create local network gateway identity for the c8000vs
resource "azurerm_local_network_gateway" "c8000v-lngw" {
  count = 2
  name                = "${azurerm_virtual_machine.c8000v[count.index].name}-lngw"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location

  #peer to public IP
  gateway_address     = azurerm_public_ip.c8000v-pubips[count.index].ip_address
  address_space       = ["1.1.1.${count.index}/32"]

  bgp_settings {
    asn = local.csr-bgp-ASN
    bgp_peering_address = "1.1.1.${count.index}"
  }
}

#add connection between vgw and c8000v
resource "azurerm_virtual_network_gateway_connection" "c8000v-conn" {
  count=2
  name                = "${local.csr-prefix}-${count.index}-conn"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location

  enable_bgp    = true

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.net1-vgw.id
  local_network_gateway_id   = azurerm_local_network_gateway.c8000v-lngw[count.index].id

  shared_key = "4v3ry53cr371p53c5h4r3dk3y"
}