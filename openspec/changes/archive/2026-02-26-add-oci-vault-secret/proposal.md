## Why

Applications running on our OKE cluster need a secure way to store and retrieve sensitive configurations like database passwords, API keys, and TLS certificates. While we now have an OCI Vault provisioned, we need a Terraform module to manage the actual secrets (`oci_vault_secret`) stored within that vault so they can be securely referenced by infrastructure or applications.

## What Changes

- Create a new Terraform module (`modules/vault-secret`) to manage secrets within an OCI Vault.
- Support provisioning multiple secrets from a map of secret configurations.
- Securely handle secret contents by allowing base64 encoded strings or plain text, supporting both dummy initial values (to be rotated later) or injected CI/CD values.
- Expose the secret OCIDs as module outputs for consumption by other infrastructure components (like Kubernetes external secrets).

## Capabilities

### New Capabilities
- `oci-vault-secret`: Provisioning and managing OCI Vault Secrets and their contents.

### Modified Capabilities

## Impact

- **Infrastructure**: A new `vault-secret` module will be added to `/modules/vault-secret`.
- **Root Module**: `main.tf` will be updated to instantiate the vault-secret module. Variable definitions (`variables.tf`) and outputs (`outputs.tf`) will be updated to support the secret configuration.
- **Security**: Secret contents will be managed via Terraform state. We will document best practices for injecting secret contents (e.g., `TF_VAR_` environment variables) to ensure sensitive data is not committed to version control.
