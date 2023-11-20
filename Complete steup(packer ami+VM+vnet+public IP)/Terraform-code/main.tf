terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.81.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_secret = "q1T8Q~WPhKy~DV6lzIIibhTOHs6LV1Lk_Tbyy"
  client_id = "577ef5f3-4c99-b9d9-6d116d398259"
  tenant_id= "aa225ace-9a-944d-bb7f853c4baa"
  subscription_id= "46dbddfee-4055-8cca-74f21476c43e"
}

#Create resource group 
resource "azurerm_resource_group" "first-terraform" {
  name = local.resource_group
  location = local.location
}

#Create security group
resource "azurerm_network_security_group" "sgTerraform" {
  name                = "SG-Terraform"
  location            = azurerm_resource_group.first-terraform.location
  resource_group_name = azurerm_resource_group.first-terraform.name

  depends_on = [ azurerm_resource_group.first-terraform ]
}
#Create Virtual network and subnet
resource "azurerm_virtual_network" "VnetTerraform" {
  name                = "Vnet-Terraform"
  location            = azurerm_resource_group.first-terraform.location
  resource_group_name = azurerm_resource_group.first-terraform.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24" 
  } 
  depends_on = [ azurerm_network_security_group.sgTerraform ]
}

#Create Network interface
resource "azurerm_network_interface" "NicTerra" {
  name                = "NIC-Terraform"
  location            = azurerm_resource_group.first-terraform.location
  resource_group_name = azurerm_resource_group.first-terraform.name

  ip_configuration {
    name                          = "TestIpTerra"
    subnet_id                     = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.PubIPTerra.id
  }
  depends_on = [ 
    azurerm_virtual_network.VnetTerraform,
    azurerm_public_ip.PubIPTerra
   ]
}
#Create one public Ip
resource "azurerm_public_ip" "PubIPTerra" {
  name                = "PublicIPTerraform"
  resource_group_name = azurerm_resource_group.first-terraform.name
  location            = azurerm_resource_group.first-terraform.location
  allocation_method   = "Static"

}
#Creste Virtual machine with packer image
resource "azurerm_virtual_machine" "VmTerra" {
  name                  = "VM-Terraform"
  location              = azurerm_resource_group.first-terraform.location
  resource_group_name   = azurerm_resource_group.first-terraform.name
  network_interface_ids = [azurerm_network_interface.NicTerra.id]
  vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    id="${data.azurerm_image.search.id}"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "azureuser"
    admin_password = "Deepu@123#123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
 
}
