# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

#CVD SD-WAN based transit design for DMVPN on c8000v to service side vnet
#this is a lab, should be ok
locals {
  csr-prefix = "8000v"
  csr-bgp-ASN = 64600
}

variable "lab_password" {
  description = "password for vms"
  type        = string
  sensitive   = true
}

resource "azurerm_resource_group" "c8000v" {
  name     = "8000v-tf_rg"
  location = "Australia SouthEast"
}

#internal subnet
resource "azurerm_virtual_network" "internal-1" {
  name                = "c8000v-internal_vn"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location
  address_space       = ["192.168.0.0/23"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal-net1"
  resource_group_name  = azurerm_resource_group.c8000v.name
  virtual_network_name = azurerm_virtual_network.internal-1.name
  address_prefixes     = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "internal-gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.c8000v.name
  virtual_network_name = azurerm_virtual_network.internal-1.name
  address_prefixes     = ["192.168.1.0/24"]
}


#transit net for 8000v
resource "azurerm_virtual_network" "transit-1" {
  name                = "c8000v-transit_vn"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "transit-sub" {
  name                 = "transit-public"
  resource_group_name  = azurerm_resource_group.c8000v.name
  virtual_network_name = azurerm_virtual_network.transit-1.name
  address_prefixes     = ["10.0.0.0/26"]
}