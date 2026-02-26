output "secret_ids" {
  description = "Map of secret logical keys (format: vaultname_secretkey) to their OCIDs"
  value       = { for k, v in oci_vault_secret.this : k => v.id }
}
