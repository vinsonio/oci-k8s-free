## Context

The project already provisions networking, compute, Kubernetes, bastion, VPN, observability, and vault resources within OCI's Always Free tier. However, the 20 GB of Always Free Object Storage (combinable across Standard, Infrequent Access, and Archive tiers) is unused.

Workloads on the cluster (e.g., backup jobs, static asset serving, cold data archival) need a durable, zero-cost storage layer. The OCI `oci_objectstorage_bucket` resource is already available in the `oracle/oci ~> 5.39` provider currently in use — no new providers are required.

The module follows the same pattern established by `modules/vault`: a `for_each` across an input map, gated by a creation flag (`create_object_storage`), all with safe opt-in defaults.

## Goals / Non-Goals

**Goals:**
- Introduce a new child module `modules/object-storage/` that creates OCI Object Storage buckets with configurable storage tier (Standard, InfrequentAccess, or Archive)
- Support multiple named buckets via a map input variable (mirrors vault module pattern)
- Gate the entire module behind a boolean `create_object_storage` flag (default `false`)
- Export bucket names and namespace as Terraform outputs for downstream consumption
- Stay within Always Free limits: ≤ 20 GB combined across all tiers, ≤ 50,000 API requests/month
- Wire the new module into the root module (`main.tf`, `variables.tf`, `outputs.tf`)
- Update `terraform.tfvars.example` with example configuration

**Non-Goals:**
- Object lifecycle management policies (can be added later)
- Pre-authenticated requests or CORS configuration
- Cross-region replication (not an Always Free feature)
- KMS customer-managed encryption (requires paid HSM vault key)
- Kubernetes PersistentVolume integration (fuse driver setup is out of scope)

## Decisions

### Decision 1: Module structure mirrors `modules/vault/`

**Choice**: Use a `for_each` over a `map(object(...))` input variable named `buckets`, with a top-level `create_object_storage` boolean flag.

**Rationale**: Consistent with the existing vault and vault-secret pattern. Users already understand how to configure maps of resources. An empty `local.buckets = var.create_object_storage ? var.buckets : {}` idiom keeps the module self-contained.

**Alternative considered**: A single-bucket module. Rejected because multiple use cases (standard + archive) are likely from day one and the map pattern requires no structural change to add more buckets.

---

### Decision 2: Storage tier as a per-bucket attribute

**Choice**: Each entry in the `buckets` map carries a `storage_tier` attribute (`"Standard"`, `"InfrequentAccess"`, or `"Archive"`).

**Rationale**: OCI buckets are single-tier; a single bucket cannot span tiers. Exposing the tier per bucket allows users to configure, for example, one Standard bucket for primary data and one Archive bucket for cold backups — all within the 20 GB combined cap.

**Alternative considered**: A single top-level default tier with per-bucket override. Too complex for the current need; per-bucket attribute is simpler.

---

### Decision 3: Access type defaults to private (`NoPublicAccess`)

**Choice**: Default `access_type = "NoPublicAccess"` for all buckets. Allow per-bucket override to `"ObjectRead"` or `"ObjectReadWithoutList"`.

**Rationale**: Follows the project's least-privilege security posture. Public buckets would be a security risk for the majority of use cases here (backups, cluster data).

---

### Decision 4: Namespace sourced via data source inside the module

**Choice**: The module fetches `data "oci_objectstorage_namespace" "this"` internally rather than requiring the caller to pass it as a variable.

**Rationale**: The namespace is a tenancy-scoped constant tied to the `compartment_ocid`. Fetching it inside the module removes friction from the root module and follows the same approach used in the provider documentation examples.

## Risks / Trade-offs

- **Always Free cap enforcement**: Terraform does not natively prevent a user from filling more than 20 GB. → Mitigation: Document the 20 GB limit prominently in `terraform.tfvars.example` and the module README. Consider adding a validation that warns large `buckets` maps.
- **Namespace is tenancy-scoped**: The namespace data source requires an authenticated provider configured with the correct tenancy. → Mitigation: No action needed; all other resources already depend on authenticated provider.
- **Archive restore latency**: Data stored in Archive tier requires a restore operation before download (OCI restriction). → Mitigation: Document in `terraform.tfvars.example`; this is expected behavior.

## Migration Plan

1. Add `modules/object-storage/` with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
2. Add optional module block in root `main.tf` gated by `create_object_storage`
3. Add `create_object_storage` and `object_storage_buckets` variables to root `variables.tf`
4. Add outputs for bucket names and namespace to root `outputs.tf`
5. Update `terraform.tfvars.example` with commented-out example
6. No rollback risk — the module is additive and opt-in; existing state is unaffected if flag is `false`

## Open Questions

- None — all required decisions are resolved above.
