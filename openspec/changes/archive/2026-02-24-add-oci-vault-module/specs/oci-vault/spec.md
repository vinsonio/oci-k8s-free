## ADDED Requirements

### Requirement: OCI Vault Provisioning
The system SHALL provision an OCI Vault configured for the Always Free tier.

#### Scenario: Default shared vault creation
- **WHEN** the vault module is invoked with default settings
- **THEN** a single OCI Vault is created in the specified compartment

#### Scenario: Multiple vault creation
- **WHEN** the vault module is invoked with a map of vault names
- **THEN** multiple OCI Vaults corresponding to the map are created

### Requirement: Master Encryption Key Provisioning
The system SHALL provision a Master Encryption Key (MEK) for each created Vault, configured with SOFTWARE protection mode to comply with the free tier.

#### Scenario: Default key creation
- **WHEN** a vault is created
- **THEN** a corresponding Master Encryption Key using AES-256 and SOFTWARE protection mode is created within that vault

### Requirement: Identifier Export
The module SHALL export the OCIDs of the created Vaults and Master Encryption Keys.

#### Scenario: Outputs for root module consumption
- **WHEN** the module completes provisioning
- **THEN** the `vault_ids` and `master_encryption_key_ids` are available as Terraform outputs
