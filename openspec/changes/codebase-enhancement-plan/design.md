## Context

The project provisions a production-hardened OKE cluster on OCI's Always-Free tier. A full codebase audit surfaced six gaps across resilience, usability, free-tier coverage, and CI quality:

1. Worker nodes are hard-coded to a single availability domain (`ads[0]`), defeating OCI's built-in multi-AD HA.
2. No SSH public key is injected into worker nodes, making direct shell access via the OCI Bastion Service cumbersome.
3. The Always-Free ATP Autonomous Database (2 DBs × 20 GB) is documented in `ALWAYS-FREE-RESOURCES.md` but has no Terraform module.
4. `modules/mysql/versions.tf` uses an unbounded `>= 5.39.0` OCI provider constraint while every other module uses the project-standard `~> 5.39`.
5. `terraform.tfvars.example` still references `create_load_balancer`, a variable removed in a prior refactor, which breaks first-run configuration.
6. `.tflint.hcl` does not enable the official `tflint-ruleset-oci` plugin, leaving OCI-specific resource issues undetected in CI.

## Goals / Non-Goals

**Goals:**
- Enable multi-AD node pool placement via a new `node_placement_ads` variable.
- Allow SSH key injection into OKE worker nodes via a new `ssh_public_key` variable.
- Add an `autonomous-database` module that provisions an Always-Free ATP instance following the existing optional-module pattern.
- Align provider version constraints to `~> 5.39` uniformly.
- Remove the stale `create_load_balancer` reference from `terraform.tfvars.example`.
- Integrate the `tflint-ruleset-oci` plugin into `.tflint.hcl` and the CI workflow.

**Non-Goals:**
- Auto-scaling or autoscaler add-ons.
- Multi-cluster or multi-region orchestration.
- TLS certificate management (cert-manager is out of scope).
- ADB wallet download automation; the wallet ZIP output reference is sufficient for users to retrieve it via the OCI CLI.
- Changing the OCI Autonomous Database type from ATP (`OLTP`) to ADW (`DW`).

## Decisions

### Decision 1: `node_placement_ads` as `list(number)` with dynamic `placement_configs` blocks
**Choice**: Add `node_placement_ads = list(number)` (default `[0]`) and replace the single static `placement_configs` block with a `dynamic "placement_configs"` that iterates over the list.  
**Rationale**: This is the minimal Terraform-idiomatic change — it preserves the existing single-AD default and requires no state migration for users who don't change the variable. The `data.oci_identity_availability_domains.ads` data source already exists in the `kubernetes` module, so no new data source is needed.  
**Alternative considered**: Accepting AD names directly as strings rather than indices. *Rejected* because it forces users to look up AD names (which are region-specific and opaque, e.g., `qFAy:US-PHOENIX-AD-1`), while indices are simpler and the data source is already available.

### Decision 2: SSH key as an optional string injected via `node_source_details.ssh_public_key`-equivalent attribute
**Choice**: Add `ssh_public_key = string` (default `""`) to the `kubernetes` module and root. When non-empty, set the `ssh_public_key` top-level argument on `oci_containerengine_node_pool.pool1`. When empty, omit it entirely to avoid triggering a no-op node pool replacement.  
**Rationale**: OCI provider's `oci_containerengine_node_pool` resource supports a top-level `ssh_public_key` string argument. Using `null` (via `var.ssh_public_key != "" ? var.ssh_public_key : null`) allows Terraform to omit the field cleanly when not needed.  
**Alternative considered**: Using a `lifecycle { ignore_changes }` block. *Rejected* because it hides legitimate drift.

### Decision 3: ADB module mirrors the `mysql` module pattern (count-based, dedicated subnet)
**Choice**: Create `modules/autonomous-database/` with the same structure as `modules/mysql/`. The `networking` module gains a `create_autonomous_database` variable and a new ADB subnet (`10.0.4.0/24`) behind a `count` guard, mirroring the `mysql` subnet (`10.0.3.0/24`). A `random_password` for the ADB admin is generated at root scope, identical to the MySQL pattern.  
**Rationale**: Consistency with the established optional-module pattern reduces cognitive load. All optional subnets in the networking module use `count = var.create_X ? 1 : 0`; adding a new one follows the same structure with no architectural surprises.  
**Alternative considered**: Reusing the MySQL subnet. *Rejected* because ADB and MySQL have different security requirements and the VCN has ample CIDR space.

### Decision 4: Provider version constraint uniformity — `~> 5.39` everywhere
**Choice**: Change `modules/mysql/versions.tf` from `>= 5.39.0` to `~> 5.39`.  
**Rationale**: Pessimistic constraints prevent unintentional major-version jumps and match every other module in the repository. This is a one-line fix with no functional impact.

### Decision 5: TFLint OCI plugin via `plugin` block in `.tflint.hcl`; `tflint --init` in CI
**Choice**: Add the `tflint-ruleset-oci` plugin block pinned to `~> 0.3` in `.tflint.hcl`, and insert a `tflint --init` step before the existing `tflint -f compact` step in the CI workflow.  
**Rationale**: TFLint's OCI ruleset catches deprecated shapes, unsupported attribute combinations, and other provider-specific mistakes that the generic ruleset misses. Pinning to `~> 0.3` matches the project's pessimistic constraint convention.

## Risks / Trade-offs

- **[Risk] Multi-AD: node pool replacement on AD index change.** Changing `node_placement_ads` after initial provisioning triggers a node pool update, which OCI may implement as a rolling node replacement. Worker workloads will be rescheduled.  
  *Mitigation*: Document in `README.md` and `terraform.tfvars.example` that changing the AD list after first apply triggers a rolling node replacement. Recommend setting the desired ADs before first apply.

- **[Risk] SSH key change triggers node pool update.** Setting `ssh_public_key` on an existing pool (or changing it) will trigger a node pool update/replacement per OCI provider behaviour.  
  *Mitigation*: Document the side-effect and recommend setting the key before first apply.

- **[Risk] ADB Always-Free quota.** OCI permits 2 Always-Free ADB instances per tenancy. Provisioning more will incur billing. The root variable is a boolean that provisions 1 instance.  
  *Mitigation*: Add a prominent note in `docs/ALWAYS-FREE-RESOURCES.md` and `README.md`.

- **[Risk] TFLint OCI plugin CI latency.** The `tflint --init` step downloads the OCI ruleset plugin at CI runtime, adding ~10–15 seconds.  
  *Mitigation*: Acceptable for this project's CI cadence; no caching needed at this scale.

## Migration Plan

All changes are backwards-compatible:
- `node_placement_ads` defaults to `[0]` → existing single-AD deployments are unaffected.
- `ssh_public_key` defaults to `""` → node pool is unchanged for existing deployments.
- `create_autonomous_database` defaults to `false` → no new resources unless explicitly enabled.
- Provider version pin change is non-functional.
- `terraform.tfvars.example` fix is documentation-only.
- TFLint plugin change affects CI only.

No `terraform state mv` commands are required.
