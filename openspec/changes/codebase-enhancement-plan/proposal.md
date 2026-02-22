## Why

The project delivers a solid free-tier OKE cluster, but several gaps have been identified through a full codebase review that reduce usability, resilience, and correctness:

1. **Multi-AD node distribution** — Worker nodes are pinned to `ads[0]`. When `node_pool_size > 1`, all nodes land in the same availability domain, defeating the HA benefit that OCI offers for free.
2. **SSH key injection for worker nodes** — There is no mechanism to inject an SSH public key into worker nodes, making operator access unnecessarily difficult even when the OCI Bastion Service is enabled.
3. **OCI Autonomous Database module** — The Always-Free tier includes 2 Autonomous Databases (ADB-S, 20 GB each) which are documented in `docs/ALWAYS-FREE-RESOURCES.md` but have no corresponding Terraform module, leaving a valuable free-tier resource unexploited.
4. **Provider version constraint inconsistency** — `modules/mysql/versions.tf` pins the OCI provider with `>= 5.39.0` (unbounded upper range) while every other module uses the pessimistic `~> 5.39` constraint. This deviates from the established convention and could allow unexpected major-version upgrades.
5. **Stale variable reference in tfvars.example** — `terraform.tfvars.example` still contains `create_load_balancer = false`, a variable that no longer exists after the load-balancer split into `create_network_load_balancer` / `create_application_load_balancer`. This breaks first-run configuration.
6. **TFLint OCI plugin missing** — `.tflint.hcl` only enables generic Terraform rules. The official `terraform-linters/tflint-ruleset-oci` plugin is not configured, so OCI-specific resource issues go undetected in CI.

## What Changes

### 1 — Multi-AD Node Distribution
- Add a `node_placement_ads` variable (list of AD indices, default `[0]`) to the `kubernetes` module and the root module.
- Update `oci_containerengine_node_pool.pool1` to emit one `placement_configs` block per entry in `node_placement_ads`, distributing nodes across the specified ADs.
- Validate that the list is non-empty and that each index is `>= 0`. Warn in documentation that OCI regions expose 1–3 ADs; users must not specify an index that exceeds the region's AD count (which the existing `data.oci_identity_availability_domains` data source already fetches in the `kubernetes` module and can be reused).
- Update `terraform.tfvars.example` and the README with guidance on multi-AD placement.

### 2 — SSH Public Key for Worker Nodes
- Add an optional `ssh_public_key` variable (type `string`, default `""`) to the `kubernetes` module and root module.
- Inject it into `oci_containerengine_node_pool.pool1` via the `ssh_public_key` argument when the value is non-empty.
- Document the variable in `terraform.tfvars.example` and the README "Accessing Worker Nodes" section.

### 3 — OCI Autonomous Database (ADB-S) Module
- Add `modules/autonomous-database/` with `main.tf`, `variables.tf`, `outputs.tf`, and `versions.tf`.
- Provision an `oci_database_autonomous_database` with `db_workload = "OLTP"` (ATP) and `is_free_tier = true` when `create_autonomous_database = true`.
- Add a dedicated ADB subnet (`10.0.4.0/24`) and security list to the `networking` module (gated on the new flag).
- Expose `autonomous_database_id`, `autonomous_database_connection_strings`, and `autonomous_database_wallet_zip` outputs at the root module.
- Add `create_autonomous_database` and `autonomous_database_admin_password` (sensitive, randomly generated) variables to the root module.
- Update `terraform.tfvars.example`, `docs/ALWAYS-FREE-RESOURCES.md`, and the root `README.md`.

### 4 — Provider Version Constraint Consistency
- Change `modules/mysql/versions.tf` from `version = ">= 5.39.0"` to `version = "~> 5.39"` to match all other modules.

### 5 — Fix `terraform.tfvars.example` Stale Variable
- Remove the `create_load_balancer = false` line and replace it with commented-out examples for `create_network_load_balancer` and `create_application_load_balancer`, matching the current variable names.

### 6 — TFLint OCI Plugin Configuration
- Add the `terraform-linters/tflint-ruleset-oci` plugin block to `.tflint.hcl` so that OCI-resource-specific rules (deprecated shapes, unsupported attributes, etc.) are enforced in CI.
- Pin the plugin version to `~> 0.3`.
- Update the CI workflow to install the plugin during `tflint --init`.

## Capabilities

### New Capabilities

- `multi-ad-node-placement`: Worker nodes can be spread across up to three availability domains by configuring `node_placement_ads`, improving cluster resilience at no extra cost.
- `worker-node-ssh-access`: An optional `ssh_public_key` variable injects operator SSH credentials into node pool nodes, enabling direct shell access via the OCI Bastion Service.
- `autonomous-database`: An optional `create_autonomous_database` flag provisions an Always-Free Oracle ATP Autonomous Database instance with a dedicated subnet, security rules, and Terraform-managed admin credentials.

### Modified Capabilities

- `network-load-balancer` / `multiple-load-balancers`: No logic change; `terraform.tfvars.example` updated to reflect current variable names.
- Internal quality: provider version constraint in `modules/mysql` aligned to project convention; TFLint OCI plugin added to CI.

## Impact

- **New files**: `modules/autonomous-database/main.tf`, `modules/autonomous-database/variables.tf`, `modules/autonomous-database/outputs.tf`, `modules/autonomous-database/versions.tf`
- **Modified files**: `modules/kubernetes/main.tf`, `modules/kubernetes/variables.tf`, `modules/networking/main.tf`, `modules/networking/variables.tf`, `modules/mysql/versions.tf`, `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars.example`, `.tflint.hcl`, `README.md`, `docs/ALWAYS-FREE-RESOURCES.md`
- **Always-Free constraints**: All additions (ADB-S, multi-AD placement, SSH key) remain within OCI Always-Free quotas. No new paid services are introduced.
- **Backwards compatibility**: All new variables default to their current implicit values (`node_placement_ads = [0]`, `ssh_public_key = ""`, `create_autonomous_database = false`), so existing `terraform.tfvars` files require no changes.
- **State impact**: Enhancements 4–6 are non-destructive. Enhancement 1–3 add new resources only when explicitly enabled. Enhancement 1 changes the `placement_configs` block count on the node pool when `node_placement_ads` is changed from the default, which triggers a node pool update (rolling replacement of nodes).
