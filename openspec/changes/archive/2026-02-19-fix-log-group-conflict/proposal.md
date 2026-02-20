## Why

The observability module has two distinct Terraform deployment failures:

1. **Log group name conflict**: `oci_logging_log_group.k8s_main` uses a hardcoded `display_name = "k8s-logs"`. OCI enforces compartment-level uniqueness for log group display names, so re-provisioning after a previous deployment (or state loss) always fails with a `409-Conflict`.

2. **Duplicate log source conflict**: Both `oci_logging_log.k8s_api_flow_log` and `oci_logging_log.k8s_worker_flow_log` have identical `configuration.source` blocks (`category = "vcn"`, `service = "flowlogs"`, `resource = var.vcn_id`). OCI disallows two logs with the same service/resource/category combination within a log group. The first log is created successfully, but the second always fails with a `409-Conflict`.

Together these errors make the observability module undeployable in any environment where it was previously applied (or where state is clean).

## What Changes

- Replace the hardcoded `display_name = "k8s-logs"` in `modules/observability/main.tf` with a cluster-scoped name: `"${var.cluster_name}-logs"`.
- Add the `cluster_name` input variable to `modules/observability/variables.tf`.
- Pass `cluster_name` from the root `main.tf` module call into the `observability` module.
- Remove the duplicate `oci_logging_log.k8s_worker_flow_log` resource — a single VCN flow log captures all traffic for the VCN (both API and worker node subnets), so a second log on the same source is redundant and invalid.
- Rename `k8s_api_flow_log` to `k8s_vcn_flow_log` (or give it a more accurate `display_name`) to reflect that it covers the whole VCN, not just the API subnet.

## Capabilities

### New Capabilities

- `observability-log-group`: OCI log group provisioning that uses a cluster-scoped, unique display name (derived from `cluster_name`) to prevent naming conflicts across deployments.
- `observability-vcn-flow-log`: A single deduplicated VCN flow log resource, correctly capturing traffic across all subnets without violating OCI's one-log-per-source constraint.

### Modified Capabilities

<!-- No existing specs — this is a net-new capability being fixed before initial stable deployment. -->

## Impact

- **Files changed**: `modules/observability/main.tf`, `modules/observability/variables.tf`, root `main.tf`
- **Terraform state**: The log group was successfully created in the latest apply (`ocid1.loggroup...`). The worker flow log was NOT created. After this fix, `terraform plan` should show only a rename of the log group display name (requires destroy+recreate or `terraform state mv` if needed) and creation of the single flow log.
- **No breaking changes to outputs or other modules** — the log group ID and log IDs are not exposed as module outputs.
- **Always-Free constraints**: Unaffected — removing one redundant log resource reduces ingestion slightly; both resources are within the 10 GB/month free quota.
