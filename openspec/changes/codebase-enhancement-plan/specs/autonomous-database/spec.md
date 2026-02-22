## ADDED Requirements

### Requirement: Autonomous Database module
The system SHALL provide a `modules/autonomous-database/` Terraform module that provisions an OCI Always-Free ATP Autonomous Database when `create_autonomous_database = true`.

#### Scenario: ADB created when enabled
- **WHEN** `create_autonomous_database = true` is set
- **THEN** an `oci_database_autonomous_database` resource SHALL be provisioned with `is_free_tier = true`, `db_workload = "OLTP"`, and `license_model = "LICENSE_INCLUDED"`

#### Scenario: ADB not created by default
- **WHEN** `create_autonomous_database` is not set (default `false`)
- **THEN** no ADB resources SHALL be created and all ADB outputs SHALL return `null`

### Requirement: Always-Free ADB constraints enforced
The ADB resource SHALL set `compute_model = "ECPU"`, `compute_count = 2`, and `data_storage_size_in_gb = 20` (20 GB) to stay within Always-Free limits.

#### Scenario: Free tier attributes are set
- **WHEN** `create_autonomous_database = true`
- **THEN** `terraform plan` SHALL show `is_free_tier = true` and the compute/storage values matching Always-Free quotas

### Requirement: Dedicated ADB subnet in networking module
The `networking` module SHALL provision a dedicated private subnet (`10.0.4.0/24`) and accompanying security list for the ADB when `create_autonomous_database = true` (passed as `create_autonomous_database` variable).

#### Scenario: ADB subnet created on demand
- **WHEN** `create_autonomous_database = true`
- **THEN** a private subnet named `"autonomous-database"` SHALL exist in the VCN with egress rules permitting outbound traffic to the Oracle Services Network

#### Scenario: ADB subnet absent when disabled
- **WHEN** `create_autonomous_database = false`
- **THEN** no ADB subnet or security list SHALL be created, keeping the VCN minimal

### Requirement: ADB module outputs
The `autonomous-database` module and root module SHALL expose `autonomous_database_id` and `autonomous_database_connection_strings` as outputs. The admin password SHALL be a sensitive root output named `autonomous_database_admin_password`.

#### Scenario: Outputs available after apply
- **WHEN** `create_autonomous_database = true` and `terraform apply` succeeds
- **THEN** `terraform output autonomous_database_connection_strings` SHALL return the connection string map for the provisioned ADB

### Requirement: Randomly-generated admin password
The root module SHALL generate a random password for the ADB admin user using a `random_password` resource (similar to the existing MySQL password), and SHALL pass it to the `autonomous-database` module.

#### Scenario: Password generated on first apply
- **WHEN** `create_autonomous_database = true` is set for the first time
- **THEN** a 16-character random password SHALL be generated and stored in Terraform state as a sensitive value
