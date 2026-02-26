locals {
  flat_secrets = flatten([
    for vault_name, secrets in(var.create_vault_secrets ? var.vault_secrets : {}) : [
      for secret_key, secret_config in secrets : {
        key            = "${vault_name}_${secret_key}"
        vault_name     = vault_name
        secret_name    = secret_config.name
        secret_content = secret_config.secret_content
      }
    ]
  ])

  secrets_map = {
    for s in local.flat_secrets : s.key => s
  }
}

resource "oci_vault_secret" "this" {
  for_each       = local.secrets_map
  compartment_id = var.compartment_ocid
  vault_id       = var.vault_ids[each.value.vault_name]
  key_id         = var.key_ids[each.value.vault_name]
  secret_name    = each.value.secret_name

  secret_content {
    content_type = "BASE64"
    content      = base64encode(each.value.secret_content)
  }
}
