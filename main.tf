#############################################################################################
# S2D Build                                                                          
#############################################################################################


#############################################################################################
# Availability Sets
#############################################################################################
resource "azurerm_availability_set" "s2d-as" {
  name                         = "${var.name_prefix}S2D-AS"
  location                     = "${var.location}"
  resource_group_name          = "${var.resourceGroupName}"
  platform_update_domain_count = 3
  platform_fault_domain_count  = 2
  managed                      = true
}


#############################################################################################
# S2D Servers NSGs                                                                          
#############################################################################################

resource azurerm_network_security_group s2d-nsg {
  name                = "${var.name_prefix}S2D-NSG"
  location            = "${var.location}"
  resource_group_name = "${var.resourceGroupName}"
  security_rule {
    name                       = "AllowAllInbound"
    description                = "Allow all in"
    access                     = "Allow"
    priority                   = "100"
    protocol                   = "*"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    description                = "Allow all out"
    access                     = "Allow"
    priority                   = "105"
    protocol                   = "*"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  tags = "${var.tags}"
}

#############################################################################################
# S2D Servers NICs                                                                          
#############################################################################################

resource "azurerm_network_interface" "S2D-nics" {
  count                     = "${var.vmCount}"
  name                      = "${var.name_prefix}S2D-${count.index}-Nic1"
  location                  = "${var.location}"
  resource_group_name       = "${var.resourceGroupName}"
  network_security_group_id = "${azurerm_network_security_group.s2d-nsg.id}"
  dns_servers               = "${var.dnsServers}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

#############################################################################################
# Storage Hosts                                                                         
#############################################################################################

# This null_resource is a hack to create a dynamic list used to dynamically create the desired number of storage disks
resource "null_resource" "vmDiskCount" {
  count = "${var.vmDiskCount}"

  triggers = {
    value = "${count.index}"
  }
}

resource "azurerm_virtual_machine" "S2D" {
  count                 = "${var.vmCount}"
  name                  = "${var.name_prefix}S2D-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resourceGroupName}"
  network_interface_ids = ["${element(azurerm_network_interface.S2D-nics.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"

  primary_network_interface_id = "${element(azurerm_network_interface.S2D-nics.*.id, count.index)}"
  availability_set_id          = "${azurerm_availability_set.s2d-as.id}"

  os_profile {
    computer_name  = "${var.name_prefix}S2D-${count.index}"
    admin_username = "${var.admin_username}"
    admin_password = "${data.azurerm_key_vault_secret.secretPassword.value}"
  }

  storage_image_reference {
    publisher = "${var.storage_image_reference.publisher}"
    offer     = "${var.storage_image_reference.offer}"
    sku       = "${var.storage_image_reference.sku}"
    version   = "${var.storage_image_reference.version}"
  }

  storage_os_disk {
    name          = "${var.name_prefix}S2D-${count.index}_OSDisk"
    caching       = "${var.storage_os_disk.caching}"
    create_option = "${var.storage_os_disk.create_option}"
    os_type       = "${var.storage_os_disk.os_type}"
  }

  # This is where the magic to dynamically create storage disk operate
  dynamic "storage_data_disk" {
    for_each = "${null_resource.vmDiskCount.*.triggers.value}"
    content {
      name          = "${var.name_prefix}S2D-${count.index}_DataDisk${storage_data_disk.value + 1}"
      create_option = "Empty"
      lun           = "${storage_data_disk.value}"
      disk_size_gb  = "${var.vmDiskSize}"
      caching       = "${var.vmDiskCaching}"
    }
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

#############################################################################################
# S2D VM extensions
#############################################################################################

resource "azurerm_virtual_machine_extension" "PrepareS2DHosts" {
  count                = "${var.vmCount - 1}"
  name                 = "prepareS2DHosts"
  location             = "${var.location}"
  resource_group_name  = "${var.resourceGroupName}"
  virtual_machine_name = "${element(azurerm_virtual_machine.S2D.*.name, count.index + 1)}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.77"

  settings = <<SETTINGS
            {
                "WmfVersion": "latest",
                "configuration": {
                    "url": "https://github.com/canada-ca-terraform-modules/terraform-azurerm-storage-space-direct/raw/master/DSC/prep-s2d.ps1.zip",
                    "script": "PrepS2D.ps1",
                    "function": "PrepS2D"
                },
                "configurationArguments": {
                    "DomainName": "${var.ad_domain_name}"
                }
            }
            SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
        {
            "configurationArguments": {
                "adminCreds": {
                    "UserName": "${var.admin_username}",
                    "Password": "${data.azurerm_key_vault_secret.secretPassword.value}"
                }
            }
        }
    PROTECTED_SETTINGS
}

data "azurerm_resource_group" "storageRG" {
  name = "${var.resourceGroupName}"
}

locals {
  unique             = "${substr(sha1("${data.azurerm_resource_group.storageRG.id}"), 0, 8)}"
  witnessStorageName = "${lower("${var.name_prefix}s2d${local.unique}cw")}"
}


resource "azurerm_storage_account" "witnessStorage" {
  name                     = "${local.witnessStorageName}"
  resource_group_name      = "${var.resourceGroupName}"
  location                 = "canadacentral"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine_extension" "ConfigS2DHosts" {
    name                 = "ConfigS2DHosts"
    location             = "${var.location}"
    resource_group_name  = "${var.resourceGroupName}"
    virtual_machine_name = "${element(azurerm_virtual_machine.S2D.*.name, 0)}"
    publisher            = "Microsoft.Powershell"
    type                 = "DSC"
    type_handler_version = "2.77"
    depends_on = ["azurerm_virtual_machine_extension.PrepareS2DHosts"]

    settings = <<SETTINGS
            {
                "WmfVersion": "latest",
                "configuration": {
                    "url": "https://github.com/canada-ca-terraform-modules/terraform-azurerm-storage-space-direct/raw/master/DSC/config-s2d.ps1.zip",
                    "script": "ConfigS2D.ps1",
                    "function": "ConfigS2D"
                },
                "configurationArguments": {
                    "DomainName": "${var.ad_domain_name}",
                    "clusterName": "${var.name_prefix}CS",
                    "sofsName": "${var.sofsName}",
                    "shareName": "${var.shareName}",
                    "vmNamePrefix": "${var.name_prefix}S2D-",
                    "vmCount": "${var.vmCount}",
                    "vmDiskSize": "${var.vmDiskSize}",
                    "witnessStorageName": "${local.witnessStorageName}",
                    "witnessStorageEndpoint": "core.windows.net",
                    "ClusterIp": "${var.ClusterIp}"
                }
            }
            SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
        {
            "configurationArguments": {
                "witnessStorageKey": {
                    "userName": "PLACEHOLDER-DO-NOT-USE",
                    "password": "${azurerm_storage_account.witnessStorage.primary_access_key}"
                },
                "adminCreds": {
                    "UserName": "${var.admin_username}",
                    "Password": "${data.azurerm_key_vault_secret.secretPassword.value}"
                }
            }
        }
    PROTECTED_SETTINGS
}
