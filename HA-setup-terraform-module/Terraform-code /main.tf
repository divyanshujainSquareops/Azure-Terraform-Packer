##############                        Resoruce group name
resource "azurerm_resource_group" "RG_Terraform" {
  location = var.azurerm_resource_location
  name     = var.azurerm_resource_name
}
#create n/w security rule
module "wordpress-network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.RG_Terraform.name
  location              = azurerm_resource_group.RG_Terraform.location
  security_group_name   = "nsg-wordpress-Terraform"
  predefined_rules = []

  custom_rules = [
    {
      name                   = "myssh"
      priority               = 201
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      source_address_prefix = "10.0.0.0/16"
      destination_port_range = "22"
      description            = "description-myssh"
    },
      {
      name                    = "myhttp"
      priority                = 200
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "3306"
      description             = "description-http"
      source_address_prefix = "10.0.0.0/16"
      destination_address_prefix  ="${data.azurerm_network_interface.NicTerra_Mysql.private_ip_address}"
    },
  ]
  depends_on = [ azurerm_resource_group.RG_Terraform ,module.vnet,azurerm_network_interface.Network_interface_terraform
  ]

}
#create n/w security rule
module "mysql-network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.RG_Terraform.name
  location              = azurerm_resource_group.RG_Terraform.location
  security_group_name   = "nsg-mysql-Terraform"
  predefined_rules = []

  custom_rules = [
    {
      name                   = "wordpress-mysql-rule"
      priority               = 201
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefix = "10.0.3.0/24"
      destination_address_prefix  ="10.0.3.0/24"
    },
  ]
  depends_on = [ azurerm_resource_group.RG_Terraform,module.vnet ]
}
########################                     public rt
module "public_rt" {
  source              = "git::https://github.com/aztfm/terraform-azurerm-route-table.git"
  name                = var.azurerm_public_rt_name
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  location            = azurerm_resource_group.RG_Terraform.location
  routes = [
    { name = "route1", address_prefix = "10.0.1.0/24", next_hop_type = "VnetLocal" },
    { name = "route2", address_prefix = "10.0.2.0/24", next_hop_type = "VnetLocal" },
     ]
  disable_bgp_route_propagation = false
}

########################                     private rt
module "private_rt" {
  source              = "git::https://github.com/aztfm/terraform-azurerm-route-table.git"
  name                = var.azurerm_private_rt_name
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  location            = azurerm_resource_group.RG_Terraform.location
  routes = [
    { name = "route3", address_prefix = "10.0.3.0/24", next_hop_type = "VnetLocal" },
    { name = "route4", address_prefix = "10.0.4.0/24", next_hop_type = "VnetLocal" },
     ]
  disable_bgp_route_propagation = false
}
##########################                       Vnet + 4subnet

module "vnet" {
  source = "./vnet"
  rg_name = azurerm_resource_group.RG_Terraform.name
  rg_location = azurerm_resource_group.RG_Terraform.location
  vnet_name = "vnet-terraform"
  public_rt_id = data.azurerm_route_table.public_rt.id
  private_rt_id = data.azurerm_route_table.private_rt.id
}

################################################# public ips
module "Public-ip_module" {
  source  = "OT-terraform-azure-modules/public-ip/azure"
  allocation_method = "Static"
  public_ip_name    = ["Bastion-ip-Terraform","PublicIP-natgateway-terrafom","Application-gateway-public-ip-terraform"]
  sku               = "Standard"
  location          = azurerm_resource_group.RG_Terraform.location
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  depends_on = [ azurerm_resource_group.RG_Terraform ]
}
######################################           Nat Nat-Gateway 

resource "azurerm_nat_gateway" "natgateway" {
  name                = "natgateway-terraform"
  location            = azurerm_resource_group.RG_Terraform.location
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  sku_name            = "Standard"
  depends_on = [ azurerm_resource_group.RG_Terraform ]
}

resource "azurerm_nat_gateway_public_ip_association" "natgateway_Public_Ip_assocication" {
  nat_gateway_id       = azurerm_nat_gateway.natgateway.id
  public_ip_address_id = data.azurerm_public_ip.PublicIP-natgateway.id
  depends_on = [ azurerm_nat_gateway.natgateway,module.Public-ip_module ]
}

resource "azurerm_subnet_nat_gateway_association" "natgateway_private_subnet1_association" {
  subnet_id      = data.azurerm_subnet.private_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.natgateway.id
  depends_on = [ data.azurerm_subnet.private_subnet_1,azurerm_nat_gateway.natgateway ]
}
resource "azurerm_subnet_nat_gateway_association" "natgateway_private_subnet2_association" {
  subnet_id      = data.azurerm_subnet.private_subnet_2.id
  nat_gateway_id = azurerm_nat_gateway.natgateway.id
  depends_on = [ data.azurerm_subnet.private_subnet_1,azurerm_nat_gateway.natgateway ]
}

#################################################### azure bstion module

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-host-terraform"
  location            = azurerm_resource_group.RG_Terraform.location
  resource_group_name = azurerm_resource_group.RG_Terraform.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.bastion-subnet.id
    public_ip_address_id = data.azurerm_public_ip.publicIP-Bastion-ip.id
  }
  depends_on = [
      azurerm_resource_group.RG_Terraform,
      module.vnet,
      module.Public-ip_module
      ]
}

########################################################### Virtual Machine`s
#Create Network interface
resource "azurerm_network_interface" "Network_interface_terraform" {
   count = length(var.network_interface_names)
   name = var.network_interface_names[count.index]
  location            = azurerm_resource_group.RG_Terraform.location
  resource_group_name = azurerm_resource_group.RG_Terraform.name

  ip_configuration {
    name                          = "TestIpTerra${count.index}"
    subnet_id                     = count.index==0?data.azurerm_subnet.private_subnet_2.id:data.azurerm_subnet.private_subnet_1.id
    private_ip_address_allocation =  "Dynamic"
    
  }
  depends_on = [ 
    azurerm_resource_group.RG_Terraform,
    module.vnet
   ]
}
resource "azurerm_linux_virtual_machine" "Virtual_Machine" {
  count               = length(var.vm_names)
  name                = var.vm_names[count.index]
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  location            = azurerm_resource_group.RG_Terraform.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Deepu@123#123"
  disable_password_authentication = false

  network_interface_ids = [
    count.index == 0 ? data.azurerm_network_interface.NicTerra_Mysql.id :
    count.index == 1 ? data.azurerm_network_interface.NicTerra_wordpress1_Privatesubnet1.id :
                       data.azurerm_network_interface.NicTerra_wordpress2_Privatesubnet1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = "${count.index == 0 ? data.azurerm_image.search_Mysql_Image.id :data.azurerm_image.search-wordpress_image.id}"

  depends_on = [ 
    azurerm_resource_group.RG_Terraform,
    azurerm_network_interface.Network_interface_terraform,
    module.vnet,

  ]
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count=3
  network_interface_id      = count.index == 0 ? data.azurerm_network_interface.NicTerra_Mysql.id :count.index == 1 ? data.azurerm_network_interface.NicTerra_wordpress1_Privatesubnet1.id :data.azurerm_network_interface.NicTerra_wordpress2_Privatesubnet1.id
  network_security_group_id = count.index==0 ?data.azurerm_network_security_group.nsg-mysql.id: data.azurerm_network_security_group.nsg-wordpress.id
  depends_on = [ azurerm_network_interface.Network_interface_terraform,module.wordpress-network-security-group ]
}
resource "azurerm_subnet_network_security_group_association" "nsg_subnet_association" {
    count=2
  subnet_id                 = count.index==0?data.azurerm_subnet.private_subnet_2.id:data.azurerm_subnet.private_subnet_1.id
  network_security_group_id = count.index==0 ?data.azurerm_network_security_group.nsg-mysql.id: data.azurerm_network_security_group.nsg-wordpress.id
  depends_on = [ 
    azurerm_network_interface.Network_interface_terraform,
    module.wordpress-network-security-group 
    ]
}
resource "azurerm_virtual_machine_extension" "VM_extension_wordpress" {
  count=2
  name                 = "appVM${count.index}"
  virtual_machine_id   = count.index==0?data.azurerm_virtual_machine.Wordpress1_Private_Vm.id:data.azurerm_virtual_machine.Wordpress2_Private_Vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = jsonencode({
    script = base64encode(data.template_file.script.rendered)
  }) 
  depends_on = [ azurerm_linux_virtual_machine.Virtual_Machine ]
}
########################################################           Application Gateway
resource "azurerm_application_gateway" "Application_Gateway" {
  name                = "appgateway-terraform"
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  location            = azurerm_resource_group.RG_Terraform.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.public_subnet_1.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendIp-Gateway"
    public_ip_address_id = data.azurerm_public_ip.Application-Gateway-publicip.id
  }
   dynamic "backend_address_pool" {
    for_each = [
    {
      name         = "appgw-terraform-BP1"
      ip_addresses = ["${data.azurerm_network_interface.NicTerra_wordpress1_Privatesubnet1.private_ip_address}", "${data.azurerm_network_interface.NicTerra_wordpress2_Privatesubnet1.private_ip_address}"]
    }
  ]
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }


  backend_http_settings {
    name                  = "http-setting"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listner1"
    frontend_ip_configuration_name = "frontendIp-Gateway"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule-1"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "listner1"
    backend_address_pool_name  = "appgw-terraform-BP1"
    backend_http_settings_name = "http-setting"
  }
  depends_on = [ 
    azurerm_resource_group.RG_Terraform,
    module.vnet,
    module.Public-ip_module,
    azurerm_network_interface.Network_interface_terraform
   ]
}
################################### DNS Zone
resource "azurerm_dns_zone" "dns_zone" {
  resource_group_name = azurerm_resource_group.RG_Terraform.name

  name = "new_1.solartechengineers.shop"
}
resource "azurerm_dns_a_record" "a_record" {
  name                = "wordpress"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.RG_Terraform.name
  ttl                 = 300
  records             = ["${data.azurerm_public_ip.Application-Gateway-publicip.ip_address}"]
  depends_on = [ module.Public-ip_module,azurerm_application_gateway.Application_Gateway ]
}
