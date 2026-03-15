#Step 1: Resource group Creation using Modules
module "resource-group" {
  source = "../modules/resource-group"
  rg = var.resourcegroup
  location = var.location
}
#step 2: vNet creation
module "vnet-creation" {
  source = "../modules/vNet"
  vnet-name = var.vnet-name
  resource_group_name = module.resource-group.resource_group #variable
  location = module.resource-group.location
  address_space = var.address_space
}
#step 3: subnet creation
module "subnet" {
  source = "../modules/subnet"
  subnet_name = var.subnet_name
  resource_group_name = module.resource-group.resource_group
  virtual_network_name = module.vnet-creation.vnet_name
  address_prefixes = var.address_prefixes 
}
#Step 4 Windows VM Creations
module "windows-vm" {
  source = "../modules/windows-vm"
  for_each = var.vm_config
  vmname = each.key
  resource_group_name =  module.resource-group.resource_group
  location =  module.resource-group.location
  vmsize = each.value.vmsize
  admin_username = each.value.admin_username
  admin_password =  each.value.admin_password
  image-sku = each.value.image-sku
  subnet_id =  module.subnet.subnet-id
  nic_count =  each.value.nic_count
}