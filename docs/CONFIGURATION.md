# 📝 Configuration Options

This file details the available configuration options for the Terraform deployment.

### `terraform.tfvars` Options

```hcl
# Core OCI credentials
compartment_ocid = "ocid1.compartment.oc1...your-compartment-ocid..."
region           = "us-phoenix-1"  # us-ashburn-1, eu-frankfurt-1, ...
region_identifier = "US"  # Identifies service gateway for your region
kubernetes_version = "v1.28.0"
cluster_name       = "cluster1"
image_id         = "ocid1.image.oc1...linux-image-ocid..."

# Security
kubernetes_api_public_enabled = false  # Set to true only for dev/lab
allowed_k8s_api_cidrs = ["203.0.113.0/24"]  # Only used if public_enabled=true

# Scaling (1-4 nodes for free tier A1 Compute)
node_pool_size = 4

# Multi-AD placement (zero extra cost; set before first apply to avoid node replacement)
# ⚠️ If your region has only 1 AD (e.g. ap-singapore-1), use [0] to avoid Invalid index errors.
# node_placement_ads = [0, 1, 2]  # spread across ADs (3-AD regions)

# SSH access to worker nodes (set before first apply)
# ssh_public_key = "ssh-rsa AAAA..."

# Database
create_mysql_heatwave = false        # Set to true to create Always Free MySQL DB System
# mysql_admin_username  = "admin"    # Admin username

create_autonomous_database = false   # Set to true to create Always Free ATP Autonomous Database
# autonomous_database_db_name = "appdb"  # DB name (alphanumeric, 14 chars max)
```

### Variables with Validation

All variables in `variables.tf` include:

- Type enforcement
- Descriptions
- Validation rules (e.g., node_pool_size ∈ [1,4])
