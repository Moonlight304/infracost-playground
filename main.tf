resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "this" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "tls_private_key" "this" {
  count     = var.os_type == "linux" ? 1 : 0
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  count           = var.os_type == "linux" ? 1 : 0
  content         = tls_private_key.this[0].private_key_openssh
  filename        = "${path.module}/${var.vm_name}.pem"
  file_permission = "0600"
}

resource "azurerm_linux_virtual_machine" "this" {
  count = var.os_type == "linux" ? 1 : 0

  name                = var.vm_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.this[0].public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = var.os_type == "windows" ? 1 : 0

  name                = var.vm_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
