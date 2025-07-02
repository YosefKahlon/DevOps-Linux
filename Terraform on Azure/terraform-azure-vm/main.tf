# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "./modules/resource-group"
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source = "./modules/network"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vm_name             = var.vm_name  
}


module "vm" {
  source = "./modules/vm"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  vm_name               = var.vm_name
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_id  = module.network.network_interface_id
}



resource "azurerm_resource_group" "manual" {
  name     = "manual-import-rg"
  location = "West Europe"
}



