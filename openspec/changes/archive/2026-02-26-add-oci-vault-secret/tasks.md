## 1. Module Scaffolding

- [x] 1.1 Create `modules/vault-secret` directory
- [x] 1.2 Create `modules/vault-secret/variables.tf` with secret configuration inputs (compartment OCID, secrets map)
- [x] 1.3 Create `modules/vault-secret/outputs.tf` for exporting secret OCIDs
- [x] 1.4 Create `modules/vault-secret/main.tf` skeleton

## 2. Core Implementation

- [x] 2.1 Implement `oci_vault_secret` resource in `modules/vault-secret/main.tf` leveraging `for_each` and `base64encode()`
- [x] 2.2 Populate `modules/vault-secret/outputs.tf` with the provisioned secret identifiers

## 3. Root Module Integration

- [x] 3.1 Add `create_vault_secrets` and `vault_secrets` inputs in root `variables.tf`
- [x] 3.2 Instantiate the `vault-secret` module in root `main.tf`
- [x] 3.3 Export secret OCIDs in root `outputs.tf`
- [x] 3.4 Update `terraform.tfvars.example` with example vault secret configuration

## 4. Verification & Clean-up

- [x] 4.1 Run `terraform fmt` across the project
- [x] 4.2 Run `terraform validate` to ensure configuration syntax is correct
- [x] 4.3 Test `terraform plan` to verify the module provisions the expected resources without errors
