## ADDED Requirements

### Requirement: OCI Object Storage Bucket Provisioning
The system SHALL provision OCI Object Storage buckets within the Always Free tier when `create_object_storage` is set to `true`.

#### Scenario: Default off — no buckets when flag is false
- **WHEN** `create_object_storage` is `false`
- **THEN** no OCI Object Storage buckets are created

#### Scenario: Single bucket creation
- **WHEN** `create_object_storage` is `true` and a single entry is supplied in `object_storage_buckets`
- **THEN** one OCI Object Storage bucket is created in the specified compartment with the given name and storage tier

#### Scenario: Multiple buckets creation
- **WHEN** `create_object_storage` is `true` and multiple entries are supplied in `object_storage_buckets`
- **THEN** one OCI Object Storage bucket per map entry is created, each with its own name and storage tier

### Requirement: Storage Tier Selection Per Bucket
The system SHALL support per-bucket storage tier configuration, accepting the values `Standard`, `InfrequentAccess`, or `Archive`.

#### Scenario: Standard tier bucket
- **WHEN** a bucket entry specifies `storage_tier = "Standard"`
- **THEN** the bucket is created with OCI Standard storage tier (hot data)

#### Scenario: Infrequent Access tier bucket
- **WHEN** a bucket entry specifies `storage_tier = "InfrequentAccess"`
- **THEN** the bucket is created with OCI Infrequent Access storage tier

#### Scenario: Archive tier bucket
- **WHEN** a bucket entry specifies `storage_tier = "Archive"`
- **THEN** the bucket is created with OCI Archive storage tier (cold data)

### Requirement: Private Access by Default
The system SHALL default all buckets to private access (`NoPublicAccess`) unless explicitly overridden.

#### Scenario: Default private access
- **WHEN** a bucket entry does not specify `access_type`
- **THEN** the bucket is created with `access_type = "NoPublicAccess"`

#### Scenario: Optional public access
- **WHEN** a bucket entry specifies `access_type = "ObjectRead"` or `"ObjectReadWithoutList"`
- **THEN** the bucket is created with the specified public access level

### Requirement: Namespace Resolution
The system SHALL resolve the OCI Object Storage namespace automatically from the tenancy without requiring the caller to pass it explicitly.

#### Scenario: Namespace fetched internally
- **WHEN** the object-storage module is invoked
- **THEN** the OCI Object Storage namespace is fetched from the tenancy via a data source and used for all bucket resources

### Requirement: Output Export
The module SHALL export the bucket names and the OCI Object Storage namespace as Terraform outputs for downstream consumption by other modules or the root module.

#### Scenario: Outputs available after apply
- **WHEN** the module completes provisioning
- **THEN** `bucket_names` (map of key → bucket name), and `namespace` (string) are available as Terraform outputs

### Requirement: Always Free Constraint Compliance
The total combined storage across all provisioned buckets SHALL not exceed the OCI Always Free allocation of 20 GB and 50,000 API requests per month.

#### Scenario: Documentation of free-tier limits
- **WHEN** the module's example configuration is rendered
- **THEN** comments in `terraform.tfvars.example` clearly state the 20 GB combined cap across Standard, Infrequent Access, and Archive tiers
