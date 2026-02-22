## ADDED Requirements

### Requirement: ssh_public_key input variable
The `kubernetes` module SHALL accept an optional `ssh_public_key` variable of type `string` with a default of `""` (empty string), representing an OpenSSH public key to inject into worker nodes.

#### Scenario: No SSH key configured (default)
- **WHEN** `ssh_public_key` is not set or is set to `""`
- **THEN** the node pool SHALL NOT include an `ssh_authorized_keys_file` or equivalent SSH key argument, preserving backwards-compatible behavior and avoiding a no-op node pool update

#### Scenario: SSH key provided
- **WHEN** `ssh_public_key` is set to a valid OpenSSH public key string
- **THEN** the node pool SHALL include the key so that worker nodes accept SSH connections authenticated with the corresponding private key

### Requirement: Conditional SSH key injection
The `oci_containerengine_node_pool.pool1` resource SHALL set its `node_source_details` or the top-level `ssh_public_key` argument (whichever OCI provider attribute is applicable) only when `var.ssh_public_key != ""`.

#### Scenario: Key injected into running node pool
- **WHEN** `ssh_public_key` changes from `""` to a valid key and `terraform apply` is run
- **THEN** the node pool SHALL be updated in-place (or replaced according to OCI provider behaviour) to include the new key

### Requirement: Root module propagation
The root module SHALL declare the `ssh_public_key` variable with the same type and default, and SHALL pass it through to the `kubernetes` module.

#### Scenario: Variable passes through cleanly
- **WHEN** `ssh_public_key = "ssh-rsa AAAA..."` is set in `terraform.tfvars`
- **THEN** the value SHALL reach the `kubernetes` module and be applied to the node pool
