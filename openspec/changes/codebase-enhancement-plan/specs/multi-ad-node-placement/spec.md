## ADDED Requirements

### Requirement: node_placement_ads input variable
The `kubernetes` module SHALL accept a `node_placement_ads` input variable of type `list(number)` with a default of `[0]`, representing the zero-based indices of availability domains from the `data.oci_identity_availability_domains` data source used for worker node placement.

#### Scenario: Default single-AD deployment
- **WHEN** `node_placement_ads` is not set (default `[0]`)
- **THEN** the node pool SHALL have exactly one `placement_configs` block referencing the first availability domain, preserving backwards-compatible behavior

#### Scenario: Multi-AD deployment
- **WHEN** `node_placement_ads = [0, 1, 2]` is configured
- **THEN** the node pool SHALL have three `placement_configs` blocks, one for each specified AD index, allowing OKE to distribute nodes across all three ADs

### Requirement: Dynamic placement_configs blocks
The `oci_containerengine_node_pool.pool1` resource SHALL use a `dynamic "placement_configs"` block that iterates over `var.node_placement_ads`, emitting one placement block per entry.

#### Scenario: Correct AD references
- **WHEN** `node_placement_ads = [0, 2]` is configured in a three-AD region
- **THEN** the node pool SHALL reference `ads[0].name` and `ads[2].name` as availability domains

### Requirement: node_placement_ads validation
The `node_placement_ads` variable SHALL include a validation block that rejects empty lists and negative index values.

#### Scenario: Empty list rejected
- **WHEN** `node_placement_ads = []` is set
- **THEN** `terraform validate` SHALL fail with a clear error message indicating the list must not be empty

#### Scenario: Negative index rejected
- **WHEN** `node_placement_ads = [-1]` is set
- **THEN** `terraform validate` SHALL fail with a clear error message

### Requirement: Root module propagation
The root module SHALL declare the `node_placement_ads` variable with the same type and default, and SHALL pass it through to the `kubernetes` module.

#### Scenario: Variable passes through cleanly
- **WHEN** `node_placement_ads = [0, 1]` is set in `terraform.tfvars`
- **THEN** the value SHALL reach the `kubernetes` module without modification
