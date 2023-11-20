

locals {
  resource_group="Terraform-RG"
  location="East US2"
}

data "azurerm_subnet" "subnet1" {
  name = "subnet1"
  virtual_network_name = "Vnet-Terraform"
  resource_group_name = "Terraform-RG"
  depends_on = [ azurerm_virtual_network.VnetTerraform ]
}

data "azurerm_image" "search" {
  name                = "linux_image"
  resource_group_name = "multi-instance-resource-group"
}
