## ADDED Requirements

### Requirement: Log group display name is cluster-scoped
The observability module SHALL provision the OCI log group with a `display_name` derived from the `cluster_name` input variable (format: `"<cluster_name>-logs"`), ensuring uniqueness within a compartment across multiple cluster deployments.

#### Scenario: Log group is created with cluster-scoped name
- **WHEN** the observability module is applied with `cluster_name = "cluster1"`
- **THEN** the OCI log group `display_name` SHALL be `"cluster1-logs"`

#### Scenario: Re-provisioning does not conflict with previous deployment
- **WHEN** a log group with the cluster-scoped name already exists in the compartment
- **THEN** Terraform SHALL either reuse the existing resource (via import) or destroy+recreate it without a 409-Conflict caused by name uniqueness

#### Scenario: Multiple clusters in the same compartment do not conflict
- **WHEN** two separate Terraform deployments use `cluster_name = "cluster1"` and `cluster_name = "cluster2"` respectively in the same OCI compartment
- **THEN** each deployment SHALL create a distinct log group (`"cluster1-logs"` and `"cluster2-logs"`) without conflict

### Requirement: Observability module accepts cluster_name as input
The observability module SHALL declare a `cluster_name` input variable of type `string` with a description, and SHALL use it to construct resource display names.

#### Scenario: cluster_name is passed from root module
- **WHEN** the root `main.tf` instantiates the `observability` module
- **THEN** it SHALL pass `cluster_name = var.cluster_name` as a module argument
