## 1. Multi-AD Node Distribution

- [x] 1.1 Add `node_placement_ads` variable (`list(number)`, default `[0]`, with non-empty and non-negative validation) to `modules/kubernetes/variables.tf`.
- [x] 1.2 Replace the static `placement_configs` block in `modules/kubernetes/main.tf` with a `dynamic "placement_configs"` block that iterates over `var.node_placement_ads`, referencing `data.oci_identity_availability_domains.ads.availability_domains[each.value].name`.
- [x] 1.3 Add `node_placement_ads` variable to root `variables.tf` (same type, default, and description).
- [x] 1.4 Pass `node_placement_ads = var.node_placement_ads` to `module "kubernetes"` in root `main.tf`.
- [x] 1.5 Update `terraform.tfvars.example` to include a commented `node_placement_ads` example with a note about multi-AD regions.
- [x] 1.6 Update the `README.md` "Security Architecture" section to add a note about multi-AD placement options under the node pool configuration, and document the node pool replacement caveat when `node_placement_ads` is changed after first apply.

## 2. SSH Public Key for Worker Nodes

- [x] 2.1 Add `ssh_public_key` variable (`string`, default `""`) to `modules/kubernetes/variables.tf`.
- [x] 2.2 In `modules/kubernetes/main.tf`, add `ssh_public_key = var.ssh_public_key != "" ? var.ssh_public_key : null` to `oci_containerengine_node_pool.pool1`.
- [x] 2.3 Add `ssh_public_key` variable to root `variables.tf` (same type and default).
- [x] 2.4 Pass `ssh_public_key = var.ssh_public_key` to `module "kubernetes"` in root `main.tf`.
- [x] 2.5 Update `terraform.tfvars.example` with a commented `ssh_public_key` example.
- [x] 2.6 Update the `README.md` "Accessing Worker Nodes" section to document SSH key injection and reference the Bastion Service.

## 3. Autonomous Database Module

- [x] 3.1 Create `modules/autonomous-database/versions.tf` with `required_version = ">= 1.0"` and `oracle/oci ~> 5.39` (matching the project constraint convention).
- [x] 3.2 Create `modules/autonomous-database/variables.tf` with `compartment_ocid`, `adb_subnet_id`, `admin_password` (sensitive), `db_name`, `display_name`, and `create_autonomous_database` (bool, default `false`) variables.
- [x] 3.3 Create `modules/autonomous-database/main.tf` with `oci_database_autonomous_database.this` using `count = var.create_autonomous_database ? 1 : 0`, `is_free_tier = true`, `db_workload = "OLTP"`, `license_model = "LICENSE_INCLUDED"`, `compute_model = "ECPU"`, `compute_count = 2`, `data_storage_size_in_tbs = 0.02`.
- [x] 3.4 Create `modules/autonomous-database/outputs.tf` with `autonomous_database_id`, `autonomous_database_connection_strings`, and `autonomous_database_db_name` (all returning `null` when not created).
- [x] 3.5 Add `create_autonomous_database` variable to `modules/networking/variables.tf`.
- [x] 3.6 Add the ADB subnet (`10.0.4.0/24`) to the `subnets` local map in `modules/networking/main.tf`, and add `oci_core_subnet.autonomous_database`, `oci_core_route_table.autonomous_database`, and `oci_core_security_list.autonomous_database` resources — all gated on `count = var.create_autonomous_database ? 1 : 0` — following the existing MySQL subnet pattern.
- [x] 3.7 Add `autonomous_database_subnet_id` output to `modules/networking/outputs.tf` (returns `null` when disabled).
- [x] 3.8 Add `create_autonomous_database` and `autonomous_database_db_name` variables to root `variables.tf` (`create_autonomous_database` defaults to `false`; `autonomous_database_db_name` defaults to `"appdb"`).
- [x] 3.9 Add a `random_password.adb_admin` resource (gated on `count = var.create_autonomous_database ? 1 : 0`) to root `main.tf`, mirroring the MySQL password resource.
- [x] 3.10 Instantiate `module "autonomous_database"` in root `main.tf` passing `compartment_ocid`, `adb_subnet_id = module.networking.autonomous_database_subnet_id`, `admin_password`, `db_name`, `display_name`, and `create_autonomous_database`.
- [x] 3.11 Add `autonomous_database_id`, `autonomous_database_connection_strings`, and `autonomous_database_admin_password` (sensitive) outputs to root `outputs.tf`.
- [x] 3.12 Update `terraform.tfvars.example` with a commented `create_autonomous_database` example.
- [x] 3.13 Update `docs/ALWAYS-FREE-RESOURCES.md` to document the Always-Free ADB quota (2 instances, 20 GB each) and the new Terraform variable.
- [x] 3.14 Update the root `README.md` "Features" section to list the ADB module, and add a brief configuration section.

## 4. Quality Fixes

- [x] 4.1 Change `modules/mysql/versions.tf` OCI provider version from `>= 5.39.0` to `~> 5.39`.
- [x] 4.2 Remove the `create_load_balancer = false` line from `terraform.tfvars.example` and replace it with commented examples for `create_network_load_balancer` and `create_application_load_balancer`.
- [x] 4.3 ~~Add the `tflint-ruleset-oci` plugin block to `.tflint.hcl`~~ — Removed: `tflint-ruleset-oci` does not exist as a published plugin; plugin block and `tflint --init` CI step reverted.
- [x] 4.4 ~~Add a `tflint --init` step to `.github/workflows/terraform.yml`~~ — Reverted (no plugins to install).

## 5. Verification

- [x] 5.1 Run `terraform fmt -check -recursive` and fix any formatting issues.
- [x] 5.2 Run `terraform init -backend=false` and `terraform validate` to confirm all new resources and modules are valid.
- [x] 5.3 Run `tflint -f compact` — passes with 0 violations. (`tflint --init` removed; no external plugins.)
