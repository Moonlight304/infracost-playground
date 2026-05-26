output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.this.ip_address
}

output "vm_id" {
  description = "Resource ID of the VM"
  value       = var.os_type == "linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "private_ip_address" {
  description = "Private IP address of the VM NIC"
  value       = azurerm_network_interface.this.private_ip_address
}
