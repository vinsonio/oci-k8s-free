## Context

The Terraform project currently provisions an OCI Always Free Kubernetes cluster. While we have robust networking and compute configurations, we lack a secure, centralized way to manage application secrets or encryption keys. OCI provides Vault in its Always Free tier (up to 20 key versions and 150 secret versions), which is ideal for our use case. We want to add a self-contained module for provisioning one or more vaults, which can be utilized securely by applications running on the OKE cluster.

## Goals / Non-Goals

**Goals:**
- Create a reusable `modules/vault` Terraform module.
- Provision OCI Vault(s) and Master Encryption Key(s) leveraging the Always Free tier.
- Provide secure access configurations (e.g., exposing OCIDs for IAM policies).
- Expose the necessary identifiers (OCIDs of Vault and Key) back to the root module for use by applications.

**Non-Goals:**
- Provisioning actual application secrets inside the Vault (this should be done by the applications or via a separate process).
- Modifying the existing Kubernetes cluster to automatically inject these secrets (e.g., configuring External Secrets Operator is out of scope for this specific infrastructure module).

## Decisions

**Decision 1: Dedicated Module Structure**
- *Rationale*: We will create a dedicated `modules/vault` directory. This keeps the Vault logic encapsulated and follows the existing project pattern. It allows us to easily toggle it via a feature flag (e.g., `create_vault = true`). By default, it will be an optional module like `bastion` or `vpn`.

**Decision 2: Default to a Single Vault**
- *Rationale*: The Always Free tier supports limited resources. A single, shared vault is usually sufficient for a free-tier Kubernetes cluster. However, the module will be designed to accept a map of vault names to allow creating multiple vaults if needed.

**Decision 3: Master Encryption Key (MEK) Provisioning**
- *Rationale*: Every OCI Vault needs at least one Master Encryption Key (MEK) to encrypt secrets. The module will provision a default MEK for the created vault. The MEK's protection mode will be set to `SOFTWARE` to comply with Always Free tier constraints.

## Risks / Trade-offs

- **[Risk] Hitting Always Free Tier Limits** → *Mitigation*: The module limits default provisioning to a single Vault and MEK. Documentation will clearly state the OCI limits (20 key versions, 150 secret versions).
- **[Risk] Vault/Key Deletion Behavior** → *Mitigation*: OCI Vaults and Keys cannot be deleted immediately (they enter a scheduling deletion state up to 30 days). We will accept the default provider behavior instead of forcing `prevent_destroy`, so users can easily tear down experimental environments, but we will document this quirk.
