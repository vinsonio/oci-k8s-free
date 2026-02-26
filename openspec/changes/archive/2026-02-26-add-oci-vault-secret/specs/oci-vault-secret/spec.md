## ADDED Requirements

### Requirement: Secret Provisioning
The system SHALL provision OCI Vault Secrets within a specified Vault using a specified Master Encryption Key (MEK).

#### Scenario: Multiple secret creation
- **WHEN** the vault-secret module is invoked with a map of secret configurations
- **THEN** multiple OCI Vault Secrets corresponding to the map are created in the specified compartment

#### Scenario: Logical vault name inheritance
- **WHEN** the vault-secret module is invoked with a secret configuration specifying a `vault_name` (or omitting it to use `"default"`)
- **THEN** it internally maps the logical `vault_name` to the correct Vault OCID and Master Encryption Key OCID provided by the vault module

### Requirement: Secret Content Management
The system SHALL handle secret content securely and encode plain text inputs into base64 format as required by the OCI API.

#### Scenario: Plain text injection
- **WHEN** a plain text secret is provided to the module
- **THEN** the module correctly encodes it using `base64encode` before storing it in the OCI Vault Secret resource

### Requirement: Identifier Export
The module SHALL export the OCIDs of the created Secrets.

#### Scenario: Outputs for consumption
- **WHEN** the module completes provisioning secrets
- **THEN** the `secret_ids` are available as Terraform outputs, mapping logical secret names to their respective OCIDs
