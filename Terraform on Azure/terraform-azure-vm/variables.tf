variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
    default     = "tf-rg-modular"
}

variable "location" {
    description = "Azure region for the resources"
    type        = string
    default     = "West Europe"
}

variable "vm_name" {
    description = "Name of the virtual machine"
    type        = string
    default     = "vm-demo"
  
}

variable "admin_username" {
    description = "Admin username for the VM"
    type        = string
    default     = "azureuser"
}

variable "admin_password" {
    description = "Admin password for the VM"
    type        = string
    sensitive   = true
    default     = "TerraformDemo123"
}