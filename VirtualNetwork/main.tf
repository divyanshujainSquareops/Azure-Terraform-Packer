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
  client_secret = "_EC8Q~sqplU82I~t14D8B4SFEYldGL1kcI."
  client_id = "8badfcfb-13b-b32e-e29883267184"
  tenant_id= "aa225ace-49a-944d-bb7f853c4baa"
  subscription_id= "46dbdd8ee-4055-8cca-74f21476c43e"
}

resource "azurerm_resource_group" "first-terraform" {
  name = local.resource_group 
  location = local.location
}

resource "azurerm_network_security_group" "sgTerraform" {
  name                = "SG-Terraform"
  location            = local.location
  resource_group_name = azurerm_resource_group.first-terraform.name
}

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
}
