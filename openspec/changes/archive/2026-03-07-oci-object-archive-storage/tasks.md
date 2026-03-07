## 1. Module Scaffold

- [x] 1.1 Create directory `modules/object-storage/`
- [x] 1.2 Create `modules/object-storage/versions.tf` with required Terraform and OCI provider version constraints
- [x] 1.3 Create `modules/object-storage/variables.tf` with `create_object_storage`, `compartment_ocid`, and `buckets` (map of objects with `name`, `storage_tier`, and `access_type`) variables
- [x] 1.4 Create `modules/object-storage/main.tf` with namespace data source and `oci_objectstorage_bucket.this` resource using `for_each` over `local.buckets`
- [x] 1.5 Create `modules/object-storage/outputs.tf` exporting `bucket_names` (map of key → bucket name) and `namespace` (string)

## 2. Root Module Wiring

- [x] 2.1 Add `create_object_storage` (bool, default `false`) and `object_storage_buckets` (map of objects) input variables to root `variables.tf`
- [x] 2.2 Add `module "object_storage"` block in root `main.tf`, passing `create_object_storage`, `compartment_ocid`, and `buckets = var.object_storage_buckets`
- [x] 2.3 Add `object_storage_bucket_names` and `object_storage_namespace` outputs to root `outputs.tf`

## 3. Example Configuration

- [x] 3.1 Update `terraform.tfvars.example` with a commented-out example block showing at least one Standard and one Archive bucket, with a note that the combined cap is 20 GB and 50,000 API requests/month

## 4. Validation

- [x] 4.1 Run `terraform fmt` on all new and modified files and verify no formatting errors
- [x] 4.2 Run `terraform validate` with `create_object_storage = false` and confirm no resources are planned
- [x] 4.3 Run `terraform validate` with `create_object_storage = true` and a sample bucket map and confirm the plan includes the expected `oci_objectstorage_bucket` resources
- [x] 4.4 Run `tflint` and confirm no ruleset violations on the new module
