locals {
  buckets = var.create_object_storage ? var.buckets : {}
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "this" {
  for_each = local.buckets

  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = each.value.name
  storage_tier   = each.value.storage_tier
  access_type    = each.value.access_type

  freeform_tags = {
    "Purpose" = "always-free-object-storage"
  }
}
