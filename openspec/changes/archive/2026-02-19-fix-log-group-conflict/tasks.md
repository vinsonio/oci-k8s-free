## 1. Observability Module Interface

- [x] 1.1 Add `cluster_name` variable to `modules/observability/variables.tf` (type `string`, with description `"Name of the Kubernetes cluster, used to scope resource display names"`)
- [x] 1.2 Pass `cluster_name = var.cluster_name` into the `observability` module call in root `main.tf`

## 2. Fix Log Group Display Name

- [x] 2.1 In `modules/observability/main.tf`, update `oci_logging_log_group.k8s_main` to use `display_name = "${var.cluster_name}-logs"` instead of the hardcoded `"k8s-logs"`

## 3. Fix Duplicate VCN Flow Log

- [x] 3.1 Remove the `oci_logging_log.k8s_worker_flow_log` resource entirely from `modules/observability/main.tf`
- [x] 3.2 Rename `oci_logging_log.k8s_api_flow_log` → `oci_logging_log.k8s_vcn_flow_log` in `modules/observability/main.tf`
- [x] 3.3 Update the `display_name` of the flow log to `"${var.cluster_name}-vcn-flow-logs"` for consistency and uniqueness

## 4. State Cleanup

- [x] 4.1 Run `terraform state list` to confirm which observability resources exist in state (the log group was created; the flow logs were not)
- [x] 4.2 If `module.observability.oci_logging_log_group.k8s_main` is in state with the old display name, run `terraform apply -target=module.observability` to destroy+recreate it with the new name (or `terraform state rm` the old resource if preferred)
- [x] 4.3 Confirm no stale state entries exist for `module.observability.oci_logging_log.k8s_api_flow_log` or `module.observability.oci_logging_log.k8s_worker_flow_log`

## 5. Validation

- [x] 5.1 Run `terraform fmt modules/observability/` and confirm no formatting errors
- [x] 5.2 Run `terraform validate` from the root and confirm no errors
- [x] 5.3 Run `terraform plan -target=module.observability` and verify: one log group create/replace with name `"<cluster_name>-logs"`, one flow log create with name `"<cluster_name>-vcn-flow-logs"`, no unexpected destroys
- [x] 5.4 Run `terraform apply -target=module.observability` (or full apply) and confirm all observability resources are created successfully with no 409-Conflict errors
- [x] 5.5 Verify in OCI Console (Logging → Log Groups) that the log group and flow log appear with the correct cluster-scoped display names
