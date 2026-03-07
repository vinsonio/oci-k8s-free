## Why

The project currently provisions compute, networking, Kubernetes, and secrets infrastructure on OCI Always Free, but does not leverage the 20 GB of Always Free Object Storage (Standard + Infrequent Access + Archive tiers) available to every tenancy. Adding a Terraform module for Object and Archive Storage enables workloads running on the cluster to use durable, scalable storage (e.g., for backups, static assets, and cold data) without incurring any cost.

## What Changes

- **New module** `modules/object-storage/` — provisions one or more OCI Object Storage buckets with configurable storage tiers (Standard, Infrequent Access, Archive).
- **Root module wiring** — new optional `create_object_storage` toggle and related input variables in `variables.tf`, module call in `main.tf`, and outputs in `outputs.tf`.
- Root-level `terraform.tfvars.example` updated with example object-storage configuration.

## Capabilities

### New Capabilities

- `oci-object-storage`: Provisioning of OCI Object Storage buckets within the Always Free tier, supporting Standard, Infrequent Access, and Archive storage tiers. Covers bucket creation, naming conventions, versioning, public/private access control, and OCID output exports.

### Modified Capabilities

<!-- No existing spec-level requirements are changing -->

## Impact

- **New files**: `modules/object-storage/main.tf`, `modules/object-storage/variables.tf`, `modules/object-storage/outputs.tf`, `modules/object-storage/versions.tf`
- **Modified files**: root `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars.example`
- **Dependencies**: OCI provider `oracle/oci ~> 5.39` (already in use); no new providers needed
- **Always-Free constraint**: Total combined storage across all tiers must not exceed 20 GB; module must not set `kms_key_id` (paid HSM encryption) by default
- **No breaking changes** — all new inputs will be optional with safe defaults (`create_object_storage = false`)
