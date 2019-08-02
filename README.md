# Storage Space Direct

## Introduction

This template deploys a Microsaoft Storage Space Direct infrastructure that can be used, for example, in combination with the RDS Gateway module.

## Security Controls

The following security controls can be met through configuration of this template:

* AC-1, AC-10, AC-11, AC-11(1), AC-12, AC-14, AC-16, AC-17, AC-18, AC-18(4), AC-2 , AC-2(5), AC-20(1) , AC-20(3), AC-20(4), AC-24(1), AC-24(11), AC-3, AC-3 , AC-3(1), AC-3(3), AC-3(9), AC-4, AC-4(14), AC-6, AC-6, AC-6(1), AC-6(10), AC-6(11), AC-7, AC-8, AC-8, AC-9, AC-9(1), AI-16, AU-2, AU-3, AU-3(1), AU-3(2), AU-4, AU-5, AU-5(3), AU-8(1), AU-9, CM-10, CM-11(2), CM-2(2), CM-2(4), CM-3, CM-3(1), CM-3(6), CM-5(1), CM-6, CM-6, CM-7, CM-7, IA-1, IA-2, IA-3, IA-4(1), IA-4(4), IA-5, IA-5, IA-5(1), IA-5(13), IA-5(1c), IA-5(6), IA-5(7), IA-9, MA-2, MA-3, MA-4, MA-6, SC-10, SC-13, SC-15, SC-18(4), SC-2, SC-2, SC-23, SC-28, SC-30(5), SC-5, SC-7, SC-7(10), SC-7(16), SC-7(8), SC-8, SC-8(1), SC-8(4), SI-11, SI-14, SI-2(1), SI-3

## Dependancies

* [Resource Groups](https://github.com/canada-ca-azure-templates/resourcegroups/blob/master/readme.md)
* [Keyvault](https://github.com/canada-ca-azure-templates/keyvaults/blob/master/readme.md)
* [VNET-Subnet](https://github.com/canada-ca-azure-templates/vnet-subnet/blob/master/readme.md)

## Usage

```terraform
terraform {
  required_version = ">= 0.12.1"
}
provider "azurerm" {
  version = ">= 1.32.0"
  # subscription_id = "2de839a0-37f9-4163-a32a-e1bdb8d6eb7e"
}

data "azurerm_client_config" "current" {}

variable "location" {
  description = "Location of the network"
  default     = "canadacentral"
}

variable "envprefix" {
  description = "Prefix for the environment"
  default     = "DAZF"
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

module "rdsvms" {
  #source = "github.com/canada-ca-terraform-modules/terraform-azurerm-remote-desktop-service?ref=20190801.1"
  source = "./terraform-azurerm-storage-space-direct"

  vmCount                   = "2"
  vmDiskCount               = "3"
  ad_domain_name            = "mgmt.demo.gc.ca.local"
  name_prefix               = "DAZF"
  resourceGroupName         = "${var.envprefix}-MGMT-RDS-RG"
  admin_username            = "azureadmin"
  secretPasswordName        = "server2016DefaultPassword"
  subnetName                = "${var.envprefix}-MGMT-APP"
  vnetName                  = "${var.envprefix}-Core-NetMGMT-VNET"
  vnetResourceGroupName     = "${var.envprefix}-Core-NetMGMT-RG"
  dnsServers                = ["100.96.122.4", "100.96.122.5"]
  vm_size                   = "Standard_D2s_v3"
  keyVaultName              = "someKeyVaultName"
  keyVaultResourceGroupName = "someKeyVaultRG"
  tags                      = "${var.tags}"
}
```

## Variable Values

To be documented

## History

| Date     | Release    | Change             |
| -------- | ---------- | ------------------ |
| 20190802 | 20190802.1 | 1st module version |
