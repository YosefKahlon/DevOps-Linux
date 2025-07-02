=== Terraform Azure VM Deployment Log ===
Deployment Date: 2025-07-02 19:15:50
Script: deploy.sh
===========================================

## Step 1: Initializing Terraform

```bash
terraform init
```

**Output:**
```
[0m[1mInitializing the backend...[0m
[0m[1mInitializing modules...[0m
[0m[1mInitializing provider plugins...[0m
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v3.117.1

[0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
[0m[32m
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.[0m
```

---

## Step 2: Planning Terraform deployment

```bash
terraform plan
```

**Output:**
```
Acquiring state lock. This may take a few moments...
[0m[1mmodule.resource_group.azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular][0m
[0m[1mmodule.network.azurerm_public_ip.pip: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/publicIPAddresses/pip-vm-demo][0m
[0m[1mmodule.network.azurerm_virtual_network.vnet: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/virtualNetworks/vnet-vm-demo][0m
[0m[1mmodule.network.azurerm_network_security_group.nsg: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkSecurityGroups/nsg-vm-demo][0m
[0m[1mmodule.network.azurerm_subnet.subnet: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/virtualNetworks/vnet-vm-demo/subnets/subnet-vm-demo][0m
[0m[1mmodule.network.azurerm_network_interface.network_interface: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkInterfaces/nic-vm-demo][0m
[0m[1mmodule.network.azurerm_network_interface_security_group_association.nsg_asssoc: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkInterfaces/nic-vm-demo|/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkSecurityGroups/nsg-vm-demo][0m
[0m[1mmodule.vm.azurerm_linux_virtual_machine.vm: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Compute/virtualMachines/vm-demo][0m

[0m[1m[32mNo changes.[0m[1m Your infrastructure matches the configuration.[0m

[0mTerraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
Releasing state lock. This may take a few moments...
```

---

## Step 3: Applying Terraform configuration

```bash
terraform apply -auto-approve
```

**Output:**
```
Acquiring state lock. This may take a few moments...
[0m[1mmodule.resource_group.azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular][0m
[0m[1mmodule.network.azurerm_public_ip.pip: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/publicIPAddresses/pip-vm-demo][0m
[0m[1mmodule.network.azurerm_virtual_network.vnet: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/virtualNetworks/vnet-vm-demo][0m
[0m[1mmodule.network.azurerm_network_security_group.nsg: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkSecurityGroups/nsg-vm-demo][0m
[0m[1mmodule.network.azurerm_subnet.subnet: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/virtualNetworks/vnet-vm-demo/subnets/subnet-vm-demo][0m
[0m[1mmodule.network.azurerm_network_interface.network_interface: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkInterfaces/nic-vm-demo][0m
[0m[1mmodule.network.azurerm_network_interface_security_group_association.nsg_asssoc: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkInterfaces/nic-vm-demo|/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Network/networkSecurityGroups/nsg-vm-demo][0m
[0m[1mmodule.vm.azurerm_linux_virtual_machine.vm: Refreshing state... [id=/subscriptions/e84b1d8f-cf26-4f1b-a24f-8a11e7cc9594/resourceGroups/tf-rg-modular/providers/Microsoft.Compute/virtualMachines/vm-demo][0m

[0m[1m[32mNo changes.[0m[1m Your infrastructure matches the configuration.[0m

[0mTerraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
Releasing state lock. This may take a few moments...
[0m[1m[32m
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
[0m[0m[1m[32m
Outputs:

[0mip_address = "4.180.86.58"
rg_name = "tf-rg-modular"
ssh_command = "ssh azureuser@4.180.86.58"
```

---

Step 4: Getting VM IP Address
Command: terraform output -raw ip_address
Timestamp: 2025-07-02 19:16:40
Output: 4.180.86.58
----------------------------------------

Step 6: Setting up Web Application
Command: ./setup-webapp.sh 4.180.86.58 TerraformDemo123
Timestamp: 2025-07-02 19:17:10
Output:
----------------------------------------
Setting up web application on VM at 4.180.86.58...
Copying setup script to VM...
Executing setup script on VM...

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Hit:1 http://azure.archive.ubuntu.com/ubuntu focal InRelease
Hit:2 http://azure.archive.ubuntu.com/ubuntu focal-updates InRelease
Hit:3 http://azure.archive.ubuntu.com/ubuntu focal-backports InRelease
Hit:4 http://azure.archive.ubuntu.com/ubuntu focal-security InRelease
Reading package lists...
Building dependency tree...
Reading state information...
27 packages can be upgraded. Run 'apt list --upgradable' to see them.

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Reading package lists...
Building dependency tree...
Reading state information...
nginx is already the newest version (1.18.0-0ubuntu1.7).
0 upgraded, 0 newly installed, 0 to remove and 27 not upgraded.
Synchronizing state of nginx.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2025-07-02 15:44:25 UTC; 32min ago
       Docs: man:nginx(8)
   Main PID: 2964 (nginx)
      Tasks: 2 (limit: 1062)
     Memory: 3.7M
     CGroup: /system.slice/nginx.service
             ├─2964 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             └─2965 nginx: worker process

Jul 02 15:44:25 vm-demo systemd[1]: Starting A high performance web server and a reverse proxy server...
Jul 02 15:44:25 vm-demo systemd[1]: Started A high performance web server and a reverse proxy server.
Web application setup completed!
You can now access the web app at http://4.180.86.58

Setup completed! Testing web application...
Web application is now accessible at http://4.180.86.58
----------------------------------------

Step 7: Running Health Check
Command: ./healthcheck.sh 4.180.86.58
Timestamp: 2025-07-02 19:17:25
Output:
----------------------------------------
Web app is accessible at 4.180.86.58
----------------------------------------

=== Deployment Summary ===
Status: Deployment completed successfully
VM IP Address: 4.180.86.58
SSH Access: ssh azureuser@4.180.86.58
Web Application: http://4.180.86.58
Completion Time: 2025-07-02 19:17:25
==========================
