locals {
  vaults = var.create_vault ? var.vaults : {}
}

resource "oci_kms_vault" "this" {
  for_each       = local.vaults
  compartment_id = var.compartment_ocid
  display_name   = each.value.name
  vault_type     = "DEFAULT"
}

resource "oci_kms_key" "this" {
  for_each       = local.vaults
  compartment_id = var.compartment_ocid
  display_name   = "${each.value.name}-mek"

  key_shape {
    algorithm = "AES"
    length    = 32 # 256-bit
  }

  management_endpoint = oci_kms_vault.this[each.key].management_endpoint
  protection_mode     = "SOFTWARE"
}
