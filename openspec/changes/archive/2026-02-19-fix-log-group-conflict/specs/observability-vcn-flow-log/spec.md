## ADDED Requirements

### Requirement: Exactly one VCN flow log per log group
The observability module SHALL provision exactly one `oci_logging_log` resource for VCN flow logs. The `(service, resource, category)` tuple for this log SHALL be unique within the log group, satisfying OCI's constraint that no two logs in the same log group may share the same combination.

#### Scenario: Single VCN flow log is created successfully
- **WHEN** the observability module is applied
- **THEN** exactly one `oci_logging_log` resource SHALL be created with `service = "flowlogs"`, `category = "vcn"`, and `resource = var.vcn_id`
- **AND** no 409-Conflict error SHALL occur due to duplicate log source configuration

#### Scenario: Duplicate log resources do not exist
- **WHEN** `terraform plan` is run against the observability module
- **THEN** the plan SHALL show at most one `oci_logging_log` resource targeting the VCN
- **AND** no second log resource with the same `(service, resource, category)` tuple SHALL exist

### Requirement: VCN flow log display name is cluster-scoped
The VCN flow log `display_name` SHALL incorporate `cluster_name` to ensure uniqueness and clarity (format: `"<cluster_name>-vcn-flow-logs"`).

#### Scenario: Flow log display name includes cluster name
- **WHEN** the observability module is applied with `cluster_name = "cluster1"`
- **THEN** the OCI log `display_name` SHALL be `"cluster1-vcn-flow-logs"`

### Requirement: VCN flow log is named k8s_vcn_flow_log in Terraform
The Terraform resource identifier for the VCN flow log SHALL be `oci_logging_log.k8s_vcn_flow_log`, accurately reflecting that it captures VCN-wide traffic (not API-endpoint-specific traffic).

#### Scenario: Terraform resource address is correct
- **WHEN** `terraform state list` is run after a successful apply
- **THEN** the flow log resource SHALL appear as `module.observability.oci_logging_log.k8s_vcn_flow_log`
- **AND** no resource named `module.observability.oci_logging_log.k8s_api_flow_log` or `module.observability.oci_logging_log.k8s_worker_flow_log` SHALL exist
