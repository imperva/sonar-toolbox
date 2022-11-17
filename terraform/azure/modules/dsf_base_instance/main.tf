provider "azurerm" {
  features {}
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = var.azurerm_resource_group_name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]
  vnet_name           = var.dsf_vnet
  vnet_location       = var.location
}

module "linuxservers" {
  source                  = "Azure/compute/azurerm"
  resource_group_name     = var.azurerm_resource_group_name
  vm_hostname             = "dsf-hub"
  nb_public_ip            = 1
  allocation_method       = "Static"
  vm_os_offer             = "CentOS"
  vm_os_publisher         = "OpenLogic"
  vm_os_sku               = "7_9"
  remote_port             = "22"
  vnet_subnet_id          = module.vnet.vnet_subnets[0]
  custom_data             = filebase64("hub_cloudinit.tpl")
  vm_size                 = "Standard_F2"
  storage_account_type    = "StandardSSD_LRS"
  source_address_prefixes = var.security_group_ingress_cidrs
  admin_username          = "dsf_admin"
  admin_password          = "WEBco123#"
  delete_os_disk_on_termination = true
  # data_disk_size_gb       = 30
  # extra_disks             = [{ name = "${var.name}-data-disk", size = var.amd_disk_size }]
  identity_ids            = [""]
}

output "linux_vm_public_address" {
  value = module.linuxservers.public_ip_address
}