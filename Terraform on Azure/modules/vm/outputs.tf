# Virtual Machine Module - Outputs
output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_admin_username" {
  description = "Admin username of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.admin_username
}
