terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.81.0"
    }
  }
}
############### azure provider information
provider "azurerm" {
  features {}
  client_secret = "sUe8Q~pnn1rHDbL5VI~xdMbe1fYaaBX"
  client_id = "316529ec-24e-9947-2b904b3d01a0"
  tenant_id= "79061f-42f9-92e6-aed843caedcd"
  subscription_id= "f8e788a1-0b7a65d4af19"
}
###################### terraform state backup store in azure containers
terraform {
  backend "azurerm" {
    resource_group_name  = "Squareops"
    storage_account_name = "tfstate214154"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    sas_token = "sp=rac21Z&se=2023-11-27T13:20:21Z&spr=https&sv=2022-11-02&sr=c&sig=WK0A2dSuAdMyIeUQTrWLkmP%2BbMK%2BEv%2FHF9OrUXANlyA%3D"
  }
}
