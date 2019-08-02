variable "location" {
  description = "Location of the network"
  default     = "canadacentral"
}

variable "keyVaultName" {
  default = "PwS3-Infra-KV-simc2atbrf"
}

variable "keyVaultResourceGroupName" {
  default = "PwS3-Infra-Keyvault-RG"
}
variable "tags" {
  default = {
    "Organizations"     = "PwP0-CCC-E&O"
    "DeploymentVersion" = "2018-12-14-01"
    "Classification"    = "Unclassified"
    "Enviroment"        = "Sandbox"
    "CostCenter"        = "PwP0-EA"
    "Owner"             = "cloudteam@tpsgc-pwgsc.gc.ca"
  }
}

variable "ad_domain_name" {
  default = "mgmt.demo.gc.ca.local"
}

variable "name_prefix" { 
  description = "Naming prefix for each new resource created. 3-char min, 8-char max, lowercase alphanumeric"
}

variable "vm_size" {
  description = "Size of the S2D VMs to be created"
  default = "Standard_D2s_v3"
}

variable "vmCount" {
  description = "Number of S2D VMs to be created in cluster (Min=2, Max=3)"
  default = "2"
}

variable "vmDiskCount" {
  description = "Number of data disks on each S2D VM (Min=2, Max=32). Ensure that the VM size you've selected will support this number of data disks."
  default = 3
}

variable "vmDiskSize" {
  description = "Size of each data disk in GB on each S2D VM (Min=128, Max=1023)"
  default = "1023"
}

variable "vmDiskCaching" {
  default = "None"
}

variable "sofsName" {
  description = "Name of clustered Scale-Out File Server role"
  default = "fs01"
}

variable "shareName" {
  description = "Name of shared data folder on clustered Scale-Out File Server role"
  default = "data"
}

variable "ClusterIp" {
  description = "Desired IP for the cluster. Make sure it is unique in the scope of the Active Directory or it qill break the other cluster that use the same IP."
  default = "169.254.1.2"
}


variable "subnetName" {
  default = "PwS3-Shared-PAZ-Openshift-RG"
}

variable "appSubnetName" {
  default = "PwS3-Shared-APP-Openshift-RG"
}

variable "vnetName" {
  default = "PwS3-Infra-NetShared-VNET"
}
variable "vnetResourceGroupName" {
  default = "PwS3-Infra-NetShared-RG"
}

variable "dnsServers" {
  default = ""
}

variable "externalfqdn" {
  default = "rds.pws1.pspc-spac.ca"
  
}

variable "rdsGWIPAddress" {
  default = ""
}

variable "rdsGWIPAddress_allocation" {
  default = "Static"
}
variable "rdsBRKIPAddress" {
  default = ""
}

variable "rdsBRKIPAddress_allocation" {
  default = "Static"
}

variable "rdsSSHIPAddresses" {
  type = "list"
  default = ["ip1", "ip2"]
}

variable "rdsSSHIPAddress_allocation" {
  default = "Static"
}

variable "resourceGroupName" {
  default = "PwS3-GCInterrop-Openshift"
}

variable "admin_username" {
  default = "azureadmin"
}

variable "secretPasswordName" {
  default = "server2016DefaultPassword"
}

variable "storage_image_reference" {
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

variable "storage_os_disk" {
  default = {
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = "Windows"
  }
}
variable "DSC_URL" {
  default = "https://raw.githubusercontent.com/canada-ca-terraform-modules/terraform-azurerm-remote-desktop-service/20190801.1/DSC/Configuration.zip"
}