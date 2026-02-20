## Context

The `modules/observability` module provisions OCI Logging resources for the Kubernetes cluster. A `terraform apply` revealed two independent `409-Conflict` failures:

1. **Log group name conflict**: The `display_name = "k8s-logs"` is hardcoded. OCI enforces compartment-level uniqueness for log group display names. Any environment that previously (even partially) deployed the observability module will fail on re-provision.

2. **Duplicate log source conflict**: Both `k8s_api_flow_log` and `k8s_worker_flow_log` define identical `configuration.source` blocks — same `category = "vcn"`, `service = "flowlogs"`, `resource = var.vcn_id`. OCI's constraint is that each `(service, resource, category)` tuple may have at most one log resource per log group. The second log will always fail to create.

VCN Flow Logs operate at the VCN level, not at the subnet level. A single VCN flow log captures traffic across all subnets in that VCN, making the second resource not just invalid, but logically redundant.

## Goals / Non-Goals

**Goals:**
- Make the log group `display_name` unique per cluster by incorporating `var.cluster_name`.
- Remove the duplicate `k8s_worker_flow_log` resource; retain a single, correctly named VCN flow log.
- Thread `cluster_name` through the observability module interface without touching other modules.
- Ensure `terraform plan` produces a clean, repeatable plan after these changes.

**Non-Goals:**
- Adding per-subnet flow logs (not supported by OCI VCN flow log API; would require separate VCN resources).
- Migrating the already-created log group resource via `terraform import` (handled operationally, not in code).
- Upgrading the OCI Terraform provider version (separate concern).

## Decisions

### Decision 1: Use `"${var.cluster_name}-logs"` as the log group display name

**Rationale**: `cluster_name` is already a required root-level variable with a default of `"cluster1"`. Deriving the log group name from it makes the resource name predictable, human-readable, and unique per logical cluster. This follows the existing naming convention used in other modules (e.g., the OKE cluster uses `cluster_name` in its display name).

**Alternative considered**: Using a random suffix (`random_string` resource). Rejected — random suffixes make names non-deterministic and harder to audit without Terraform state.

### Decision 2: Remove `k8s_worker_flow_log`, rename `k8s_api_flow_log` → `k8s_vcn_flow_log`

**Rationale**: OCI VCN Flow Logs are scoped to a VCN resource, capturing all traffic crossing any subnet in that VCN. There is no mechanism to target a single subnet in a `OCISERVICE` log source with `service = "flowlogs"`. Both existing resources were pointing to the same VCN OCID, making the second one both invalid (409-Conflict) and redundant. Renaming to `k8s_vcn_flow_log` clarifies the actual scope.

**Alternative considered**: Keeping both resources but differentiating them by `category`. Rejected — OCI VCN flow logs have only one valid category (`vcn`); there are no subcategories for individual subnets via this API.

### Decision 3: Add `cluster_name` as a required input to the `observability` module

**Rationale**: The observability module is a child module and must not access root-level variables directly. Passing `cluster_name` as an explicit module input follows the existing pattern used by other modules (e.g., `kubernetes` module takes `cluster_name`). Type is `string`, no validation needed beyond what the root variable already enforces.

## Risks / Trade-offs

- **Terraform state drift**: The log group was already created with `display_name = "k8s-logs"` in the latest apply. Changing `display_name` will force a destroy + recreate of the log group (and its child log). This is safe since the log group currently contains no log data (the flow log creation failed). **Mitigation**: Document destroy+recreate in the migration plan; no data loss risk.
- **Resource rename (k8s_api_flow_log → k8s_vcn_flow_log)**: Terraform will see this as delete + create (different resource address). The old resource address no longer exists in state. **Mitigation**: Since the flow log was never successfully created, there is nothing to remove from state. A clean `terraform apply` will simply create `k8s_vcn_flow_log`.

## Migration Plan

1. Apply the code changes (this change).
2. Run `terraform plan -target=module.observability` to review the expected destroy+recreate of the log group.
   - If the log group OCID is already in state (`ocid1.loggroup...`), it will be destroyed and a new one created with the new display name. This is acceptable — no log data is retained from the partially-failed apply.
3. Run `terraform apply -target=module.observability` (or full apply) to converge.
4. Verify in OCI Console: one log group named `"<cluster_name>-logs"` and one VCN flow log.

## Open Questions

- Should `display_name` for the flow log also incorporate `cluster_name` for consistency (e.g., `"${var.cluster_name}-vcn-flow-logs"`)? **Decision**: Yes — apply the same uniqueness principle to the flow log display name for consistency and to allow multi-cluster deployments in the same compartment.
