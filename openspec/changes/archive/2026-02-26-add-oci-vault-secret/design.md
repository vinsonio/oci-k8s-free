## Context

We have an OCI Always Free Kubernetes cluster. Recently, we added a module to provision OCI Vaults and Master Encryption Keys (MEKs). To fully utilize this for applications, we need a way to manage the actual secrets stored within those vaults. This design covers a new module to manage `oci_vault_secret` resources securely via Terraform.

## Goals / Non-Goals

**Goals:**
- Create a reusable `modules/vault-secret` Terraform module.
- Provision OCI Vault Secrets linked to a specific Vault and MEK.
- Support provisioning multiple secrets via a map or list.
- Securely handle secret contents (base64 encoded) and expose the secret OCIDs.

**Non-Goals:**
- Kubernetes-side integration (e.g., configuring External Secrets Operator). This module strictly handles the OCI infrastructure side.
- Automatic secret rotation logic within Terraform.

## Decisions

**Decision 1: Separate Module for Secrets**
- *Rationale*: We are creating `modules/vault-secret` instead of appending secret logic to `modules/vault`. Managing secrets independently of the vault's lifecycle reduces the blast radius. Vaults are long-lived infrastructure, while secrets may change frequently or be managed by separate IAM roles in the future.

**Decision 2: Input Data Structure**
- *Rationale*: The root module accepts a `vault_secrets` map where each secret can specify an optional `vault_name` (defaulting to `"default"`). The `vault_secret` module receives the full outputs (`vault_ids`, `key_ids`) from the `vault` module and maps each secret to the correct Vault and Key OCID internally via this logical name. This completely eliminates the need to look up and pass specific OCIDs within the `.tfvars` file when provisioning them together.

**Decision 3: Terraform State Handling**
- *Rationale*: `oci_vault_secret` requires the secret content to be in state. While Terraform state will contain these secrets, we will document best practices for injecting these values (e.g., using `TF_VAR_` environment variables) so they are not hardcoded in `.tfvars` files.

## Risks / Trade-offs

- **[Risk] Secrets stored in Terraform State** → *Mitigation*: Standard Terraform limitation. We will document that users should inject secrets via environment variables and ensure their state files are stored securely.
- **[Risk] Hitting Always Free Limits** → *Mitigation*: OCI Always Free permits up to 150 secret versions per tenancy. We will document this constraint.
