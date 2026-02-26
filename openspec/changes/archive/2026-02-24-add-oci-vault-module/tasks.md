## 1. Module Scaffolding

- [x] 1.1 Create `modules/vault` directory
- [x] 1.2 Create `modules/vault/variables.tf` with vault configuration inputs (compartment OCID, vault map)
- [x] 1.3 Create `modules/vault/outputs.tf` for exporting vault and key OCIDs
- [x] 1.4 Create `modules/vault/main.tf` skeleton

## 2. Core Implementation

- [x] 2.1 Implement `oci_kms_vault` resource in `modules/vault/main.tf` leveraging `for_each`
- [x] 2.2 Implement `oci_kms_key` (Master Encryption Key) resource with SOFTWARE protection mode in `modules/vault/main.tf`
- [x] 2.3 Populate `modules/vault/outputs.tf` with the provisioned identifiers

## 3. Root Module Integration

- [x] 3.1 Un-comment or add `create_vault` and related inputs in root `variables.tf`
- [x] 3.2 Instantiate the `vault` module in root `main.tf`
- [x] 3.3 Export vault and key OCIDs in root `outputs.tf`
- [x] 3.4 Update `terraform.tfvars.example` with example vault configuration 

## 4. Verification & Clean-up

- [x] 4.1 Run `terraform fmt` across the project
- [x] 4.2 Run `terraform validate` to ensure configuration syntax is correct
- [x] 4.3 Run `tflint` to catch any provider-specific issues
- [x] 4.4 Test `terraform plan` to verify the module provisions the expected resources without errors
