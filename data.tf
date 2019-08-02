data "azurerm_key_vault" "keyvaultsecrets" {
  name                = "${var.keyVaultName}"
  resource_group_name = "${var.keyVaultResourceGroupName}"
}

data "azurerm_key_vault_secret" "secretPassword" {
  name         = "${var.secretPasswordName}"
  key_vault_id = "${data.azurerm_key_vault.keyvaultsecrets.id}"
}

data "azurerm_subnet" "subnet" {
  name                 = "${var.subnetName}"
  virtual_network_name = "${var.vnetName}"
  resource_group_name  = "${var.vnetResourceGroupName}"
}

data "azurerm_client_config" "current" {}