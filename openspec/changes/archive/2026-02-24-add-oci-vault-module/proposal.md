## Why

Oracle Cloud Infrastructure (OCI) Always Free tier includes OCI Vault, which provides centralized key and secret management. Currently, our free-tier Kubernetes cluster does not have a managed solution for securely storing and accessing application secrets or encryption keys. Implementing an OCI Vault module will allow us to provision and manage vaults for one or multiple applications securely within our existing infrastructure.

## What Changes

- Create a new Terraform module (`modules/vault`) to provision OCI Vault resources (Vaults and Master Encryption Keys).
- Support provisioning a single shared vault or multiple dedicated vaults for applications.
- Configure IAM policies or access rules (if applicable) to ensure secure, least-privilege access.
- Expose vault and master encryption key OCIDs as module outputs for consumption by other infrastructure components.

## Capabilities

### New Capabilities
- `oci-vault`: Provisioning and managing OCI Vaults and Master Encryption Keys.

### Modified Capabilities

## Impact

- **Infrastructure**: A new `vault` module will be added to the Terraform project `/modules/vault`.
- **Root Module**: `main.tf` will be updated to instantiate the vault module. Variable definitions (`variables.tf`) and outputs (`outputs.tf`) will be updated to support the vault configuration.
- **Security**: Applications running on the OKE cluster will be able to integrate with OCI Vault to manage secrets.
