#create service side ubuntu vm for testing
locals {
  testvm_prefix = "test-8000v-vm"
}

resource "azurerm_network_interface" "nic1" {
  name                = "${local.testvm_prefix}-nic1"
  resource_group_name = azurerm_resource_group.c8000v.name
  location            = azurerm_resource_group.c8000v.location

  ip_configuration {
    name                          = "internal-ip1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.allow-any.id
}

resource "azurerm_linux_virtual_machine" testvm-1 {
  name                  = "${local.testvm_prefix}-vm"
  location              = azurerm_resource_group.c8000v.location
  resource_group_name   = azurerm_resource_group.c8000v.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  size               = "Standard_F2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  computer_name  = local.testvm_prefix
  admin_username = "ubuntu"
  admin_password = var.lab_password
  disable_password_authentication = false
}