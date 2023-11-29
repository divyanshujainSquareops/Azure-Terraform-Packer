
####################### resource group variables ##########################
variable "azurerm_resource_name" {
    type = string
    default = "RG-Terraform-module"
    description = "terraform module name"  
}
variable "azurerm_resource_location" {
    type = string
    default = "east us2"
    description = "terraform module location"  
}
variable "azurerm_nsg1_name" {
    type = string
    default = "nsg1-terraform"
    description = "nsg1 name"  
}
#######################  route table #######################
variable "azurerm_public_rt_name" {
    type = string
    default = "public-rt-terraform"
    description = "public rt name"  
}
variable "azurerm_private_rt_name" {
    type = string
    default = "private-rt-terraform"
    description = "private rt name"  
}
data "azurerm_route_table" "public_rt" {
  name                = var.azurerm_public_rt_name
  resource_group_name = var.azurerm_resource_name
  depends_on = [ module.public_rt ]
}
data "azurerm_route_table" "private_rt" {
  name                = var.azurerm_private_rt_name
  resource_group_name = var.azurerm_resource_name
  depends_on = [ module.private_rt ]
}
#############################  VNET ###############################
data "azurerm_virtual_network" "Vnet" {
  name                = "vnet-terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ 
    azurerm_resource_group.RG_Terraform,
    module.vnet]
}
data "azurerm_subnet" "bastion-subnet" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = data.azurerm_virtual_network.Vnet.name
  resource_group_name  = var.azurerm_resource_name
  depends_on = [ module.vnet ]
}
data "azurerm_subnet" "private_subnet_1" {
  name                 = "private_subnet1"
  virtual_network_name = data.azurerm_virtual_network.Vnet.name
  resource_group_name  = var.azurerm_resource_name
  depends_on = [ module.vnet ]
}
data "azurerm_subnet" "private_subnet_2" {
  name                 = "private_subnet2"
  virtual_network_name = data.azurerm_virtual_network.Vnet.name
  resource_group_name  = var.azurerm_resource_name
  depends_on = [ module.vnet ]
}
data "azurerm_subnet" "public_subnet_1" {
  name                 = "public_subnet1"
  virtual_network_name = data.azurerm_virtual_network.Vnet.name
  resource_group_name  = var.azurerm_resource_name
  depends_on = [ module.vnet ]
}
#############################################  data soruce of Public IP`s
data "azurerm_public_ip" "PublicIP-natgateway" {
  name                = "PublicIP-natgateway-terrafom"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ module.Public-ip_module ]
}
data "azurerm_public_ip" "publicIP-Bastion-ip" {
  name                = "Bastion-ip-Terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ module.Public-ip_module ]
}
data "azurerm_public_ip" "Application-Gateway-publicip" {
  name                = "Application-gateway-public-ip-terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ module.Public-ip_module ]
}
################################# data source of nsg`s
data "azurerm_network_security_group" "nsg-wordpress" {
  name                = "nsg-wordpress-Terraform"
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  depends_on = [ module.wordpress-network-security-group]
}
data "azurerm_network_security_group" "nsg-mysql" {
  name                = "nsg-mysql-Terraform"
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  depends_on = [ module.mysql-network-security-group]
}

######################################## virtual image
data "azurerm_image" "search-wordpress_image" {
  name                = "wordpress-image"
  resource_group_name = "Squareops"
  depends_on = [ data.azurerm_subnet.private_subnet_1]
}
data "azurerm_image" "search_Mysql_Image" {
  name                = "sql-db-image"
  resource_group_name = "Squareops"
  depends_on = [ data.azurerm_subnet.private_subnet_1]
}
################################################## virtual image extention shell script variable
data "azurerm_key_vault" "key_vault" {
  name                = "Terraform-key-vault1234"
  resource_group_name = "Squareops"
}
data "azurerm_key_vault_secret" "databaseName" {
  name         = "DatabaseName"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
data "azurerm_key_vault_secret" "databaseUsername" {
  name         = "DatabaseUsername"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
data "azurerm_key_vault_secret" "databasePassword" {
  name         = "DatabasePassword"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "template_file" "script" {
  template = file("cloud-init-script.sh")

  vars = {
    database_name     = "${data.azurerm_key_vault_secret.databaseName.value}"
    database_username = "${data.azurerm_key_vault_secret.databaseUsername.value}"
    database_password = "${data.azurerm_key_vault_secret.databasePassword.value}"
    database_host     = data.azurerm_network_interface.NicTerra_Mysql.private_ip_address
  }
   depends_on = [azurerm_network_interface.Network_interface_terraform]
}

########################### network interface #####################################
variable "network_interface_names" {
  type    = list(string)
  default = ["NIC-Mysql-private-subnet1-Terraform", "NIC-wordpress1-private-subnet1-Terraform", "NIC-wordpress2-private-subnet1-Terraform"]
}

data "azurerm_network_interface" "NicTerra_Mysql" {
  name ="NIC-Mysql-private-subnet1-Terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ azurerm_network_interface.Network_interface_terraform ]  
}
data "azurerm_network_interface" "NicTerra_wordpress1_Privatesubnet1" {
  name ="NIC-wordpress1-private-subnet1-Terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ azurerm_network_interface.Network_interface_terraform ]  
}
data "azurerm_network_interface" "NicTerra_wordpress2_Privatesubnet1" {
  name ="NIC-wordpress2-private-subnet1-Terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ azurerm_network_interface.Network_interface_terraform ]  
}

################## Virtual machine
variable "vm_names" {
  type    = list(string)
  default = ["Mysql-VM-Terraform", "Wordpress1-VM-Terraform", "Wordpress2-VM-Terraform"]
}
data "azurerm_virtual_machine" "MySql_Private_Vm" {
  name="Mysql-VM-Terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ azurerm_linux_virtual_machine.Virtual_Machine ]  
  
}
data "azurerm_virtual_machine" "Wordpress1_Private_Vm" {
  name="Wordpress1-VM-Terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ azurerm_linux_virtual_machine.Virtual_Machine ]  
  
}
data "azurerm_virtual_machine" "Wordpress2_Private_Vm" {
  name="Wordpress2-VM-Terraform"
  resource_group_name = var.azurerm_resource_name
  depends_on = [ azurerm_linux_virtual_machine.Virtual_Machine ]  
  
}
