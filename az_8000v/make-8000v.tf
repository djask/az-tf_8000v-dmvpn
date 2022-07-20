#create service side ubuntu vm for testing
locals {
  csr-prefix = "8000v"
}

resource "azurerm_public_ip" "c8000v-pubips" {
    count = 2
  name                = "${local.csr-prefix}-${count.index}_pubip"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "c8000v-nics" {
    count = 2
  name                = "${local.csr-prefix}-${count.index}-nic1"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location

  ip_configuration {
    name                          = "internal-ip1"
    subnet_id                     = azurerm_subnet.transit-sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.c8000v-pubips[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "c8000v-nics-assoc" {
    count = 2
  network_interface_id      = azurerm_network_interface.c8000v-nics[count.index].id
  network_security_group_id = azurerm_network_security_group.c8000v.id
}

resource "azurerm_virtual_machine" "c8000v" {
count = 2
  name                  = "${local.csr-prefix}-${count.index}"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location
  network_interface_ids =  [azurerm_network_interface.c8000v-nics[count.index].id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "cisco"
    offer     = "cisco-c8000v"
    sku       = "17_06_03a-byol"
    version   = "17.06.0320220429"
  }
  storage_os_disk {
    name              = "${local.csr-prefix}-${count.index}-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name = "${local.csr-prefix}-${count.index}"
    admin_username = "azureuser"
    admin_password = var.lab_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
