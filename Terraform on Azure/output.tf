output "rg_name" {
  value = module.resource_group.name
}

output "ip_address" {
  value = module.network.public_ip_address
}

output "ssh_command" {
  description = "Command to SSH into the VM"
  value       = "ssh ${var.admin_username}@${module.network.public_ip_address}"
}