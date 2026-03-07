output "bucket_names" {
  description = "Map of bucket logical names to their OCI bucket names"
  value       = { for k, v in oci_objectstorage_bucket.this : k => v.name }
}

output "namespace" {
  description = "The OCI Object Storage namespace for this tenancy"
  value       = data.oci_objectstorage_namespace.this.namespace
}
