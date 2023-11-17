variable "storage_account_name"{
    type=string
    description="Please enter the storage account name"
    default = "storageterraform78o780"
}

locals {
  resource_group="Terraform"
  location="East US2"
}
