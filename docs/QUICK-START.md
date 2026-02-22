# 🚀 Quick Start

### Step 1: Set Up OCI Credentials

```bash
mkdir -p ~/.oci
# Download your private key from OCI Console → User Settings → API Keys
# Place it in ~/.oci/oci_api_key.pem
# Create ~/.oci/config with your tenancy and user details
```

Reference: [OCI SDK Authentication](https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm)

### Step 2: Configure Backend (Optional)

Using OCI Object Storage for remote state is recommended. You can generate the required **S3-compatible credentials** using the OCI CLI:

```bash
# 1. Get your User OCID (if not known)
USER_OCID=$(oci iam user get --user-id <your-user-ocid> --query "data.id" --output string)

# 2. Create the Customer Secret Key
oci iam customer-secret-key create --user-id $USER_OCID --display-name "terraform-backend"

# 3. Copy the 'key' (Secret Key) and 'id' (Access Key ID) from the output
```

**Benefits of remote state:**
- ✅ State accessible from any machine/CI/CD
- ✅ Automatic versioning and encryption
- ✅ Still 100% Always Free (20 GB storage quota)

### Step 3: Find Your Image OCID

During setup, you'll need an OS image OCID. You can list available Oracle Linux images with:

```bash
oci compute image list --compartment-id $COMPARTMENT_OCID --region us-phoenix-1 \
  --query "data[?contains(\"display_name\", 'Oracle-Linux-9')].{id:id,name:\"display_name\"}" \
  --output table
```

### Step 4: Deploy

Once configured, review your `terraform.tfvars` and run:

```bash
# If using remote state, source your environment
source .terraform.env

# Preview and apply
terraform plan
terraform apply
```

Cluster creation typically takes **5-10 minutes**. Monitor progress in OCI Console → Developer Services → Kubernetes Clusters.
