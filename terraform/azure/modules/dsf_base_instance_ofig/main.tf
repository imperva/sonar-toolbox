provider "azurerm" {
  features {}
}

# resource "azurerm_resource_group" "dsf-rg" {
#   name     = join("-", [var.name, "rg"])
#   location = var.location
# }

data "azurerm_resource_group" "dsf-rg" {
  name = var.azurerm_resource_group_name
}

# resource "azurerm_public_ip" "dsf-public-ip" {
#   name                = join("-", [var.name, "public-ip"])
#   location            = data.azurerm_resource_group.dsf-rg.location
#   resource_group_name = data.azurerm_resource_group.dsf-rg.name
#   allocation_method   = "Static"

#   tags = {
#     environment = join("-", [var.location, var.name])
#   }
# }

# resource "azurerm_network_interface" "dsf-ani" {
#   name                = join("-", [var.name, "dsf-ani"])
#   location            = data.azurerm_resource_group.dsf-rg.location
#   resource_group_name = data.azurerm_resource_group.dsf-rg.name

#   ip_configuration {
#     name                          = join("-", [var.name, "public-ip"])
#     public_ip_address_id          = azurerm_public_ip.dsf-public-ip.id
#     private_ip_address_allocation = "Static"
#   }
# }

resource "azurerm_network_interface" "dsf-ani" {
  name                = "${var.name}-dsf-ani"
  location            = data.azurerm_resource_group.dsf-rg.location
  resource_group_name = data.azurerm_resource_group.dsf-rg.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Static"
  }
}

data "azurerm_ssh_public_key" "dsf-ssh-key" {
  name                = var.azurerm_ssh_public_key_name
  resource_group_name = var.azurerm_resource_group_name
}

data "template_file" "hub_cloudinit" {
  template = file("${path.module}/hub_cloudinit.tpl")
  vars = {
    name                                = var.name
    admin_password                      = var.admin_password
    secadmin_password                   = var.secadmin_password
    sonarg_pasword                      = var.sonarg_pasword
    sonargd_pasword                     = var.sonargd_pasword
    # dsf_gateway_public_key_name         = var.dsf_gateway_public_key_name
    # dsf_gateway_private_key_name        = var.dsf_gateway_private_key_name
    # dsf_hub_public_authorized_key       = var.dsf_hub_public_authorized_key
    # s3_bucket                           = var.s3_bucket
    # dsf_version                         = var.dsf_version
    # dsf_install_tarball_path            = var.dsf_install_tarball_path
    # additional_parameters               = var.additional_parameters
    # hub_ip                              = var.hub_ip
    # uuid                                = random_uuid.uuid.result
  }
}

resource "azurerm_linux_virtual_machine" "dsf-lvm" {
  name                = var.name
  location            = data.azurerm_resource_group.dsf-rg.location
  resource_group_name = data.azurerm_resource_group.dsf-rg.name
  size                = "Standard_F2"
  # disk_size_gb        = "30" # The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
  admin_username      = var.admin_username
  user_data           = base64encode(data.template_file.hub_cloudinit.rendered)
  network_interface_ids = [
    azurerm_network_interface.dsf-ani.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_ssh_public_key.dsf-ssh-key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS" # Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS
  }

  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-7"
    sku       = "centos-7"
    version   = "1.2019.0812" # latest
  }
}

resource "azurerm_managed_disk" "dsf-managed-disk" {
  name                 = "${var.name}-disk1"
  location             = data.azurerm_resource_group.dsf-rg.location
  resource_group_name  = data.azurerm_resource_group.dsf-rg.name
  storage_account_type = "StandardSSD_LRS" # Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS
  create_option        = "Empty"
  disk_size_gb         = var.amd_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "avm-disk-attachment" {
  managed_disk_id    = azurerm_managed_disk.dsf-managed-disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.dsf-lvm.id
  lun                = "10"
  caching            = "ReadWrite"
}

########################################################
#############  Azure DSF Network Configs ###############
########################################################

resource "azurerm_virtual_network" "network" {
  name                = "${var.name}-network"
  address_space       = ["10.0.0.0/16"]
  location             = data.azurerm_resource_group.dsf-rg.location
  resource_group_name  = data.azurerm_resource_group.dsf-rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-subnet"
  resource_group_name  = data.azurerm_resource_group.dsf-rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_nat_gateway" "natgateway" {
  name                = "${var.name}-natgateway"
  location             = data.azurerm_resource_group.dsf-rg.location
  resource_group_name  = data.azurerm_resource_group.dsf-rg.name
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.natgateway.id
}

########################################################
#############  DSF Security Group Configs ##############
########################################################

resource "azurerm_network_security_group" "example" {
  name                = join("-", [var.name, "security-group"])
  location            = data.azurerm_resource_group.dsf-rg.location
  resource_group_name = data.azurerm_resource_group.dsf-rg.name

  security_rule {
    name                       = "Allow-SSH-22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = join(",",var.security_group_ingress_cidrs)
  }

  security_rule {
    name                       = "Allow-GUI-8443"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "8443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = join(",",var.security_group_ingress_cidrs)
  }

  security_rule {
    name                       = "Allow-8080"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "8080"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = join(",",var.security_group_ingress_cidrs)
  }

  security_rule {
    name                       = "Allow-10800-10899"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "10800-10899"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = join(",",var.security_group_ingress_cidrs)
  }

  tags = {
    owner = "Brian Anderson"
    team = "OCTO"
  }
}
