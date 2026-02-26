output "vault_ids" {
  description = "Map of vault logical names to their OCIDs"
  value       = { for k, v in oci_kms_vault.this : k => v.id }
}

output "master_encryption_key_ids" {
  description = "Map of vault logical names to their Master Encryption Key OCIDs"
  value       = { for k, v in oci_kms_key.this : k => v.id }
}
