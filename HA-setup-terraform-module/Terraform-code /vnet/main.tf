module "vnet" {
    source  = "Azure/vnet/azurerm"
    version = "4.1.0"
    resource_group_name = var.rg_name
    vnet_name = var.vnet_name
    use_for_each = true
    address_space       = ["10.0.0.0/16"]
    subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24","10.0.5.0/24"]
    subnet_names        = ["public_subnet1", "public_subnet2","private_subnet1","private_subnet2","AzureBastionSubnet"]
    vnet_location       = var.rg_location
    route_tables_ids = {
        public_subnet1 = var.public_rt_id
        public_subnet2 = var.public_rt_id
        private_subnet1 = var.private_rt_id
        private_subnet2 = var.private_rt_id
    }

}
