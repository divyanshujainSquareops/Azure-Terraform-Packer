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
  client_secret = "_EsqplwFgZJU82I~t14D8B4SFEYldGL1kcI."
  client_id = "8cfb-13c1-4a8b-b32e-e29883267184"
  tenant_id= "aa225ace-0-429a-944d-bb7f853c4baa"
  subscription_id= "46db-efee-4055-8cca-74f21476c43e"
}

resource "azurerm_resource_group" "first-terraform" {
  name = local.resource_group
  location = local.location
}

resource "azurerm_storage_account" "storageTerraform" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.first-terraform.name
  location                 = azurerm_resource_group.first-terraform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = true
  depends_on = [ azurerm_resource_group.first-terraform ]
}
resource "azurerm_storage_container" "TerraContainer" {
  name                  = "terraformcontainer"
  storage_account_name  = azurerm_storage_account.storageTerraform.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.storageTerraform
  ]
}

resource "azurerm_storage_blob" "example" {
  name                   = "sample.txt"
  storage_account_name   = azurerm_storage_account.storageTerraform.name
  storage_container_name = azurerm_storage_container.TerraContainer.name
  type                   = "Block"
  source                 = "sample.txt"
  depends_on = [
    azurerm_storage_container.TerraContainer
   ]
}
