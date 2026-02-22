# Create a Free Managed Kubernetes Cluster in Oracle Cloud using Terraform

Deploy a secure, production-hardened Kubernetes cluster on Oracle Cloud Infrastructure's **Always-Free tier** with Terraform, staying completely within free-tier constraints while implementing security best practices.

---

## 🎯 Features

- **100% Free Tier** — Uses OKE Basic (free), A1 Compute, and Always-Free networking + logging
- **Secure by Default** — Private Kubernetes API endpoint, encrypted traffic, least-privilege security lists
- **Network Segmentation** — Dedicated subnets for API, worker nodes, pods, and load balancers
- **Observability** — VCN Flow Logs for security auditing (10 GB/month Always-Free quota)
- **High Availability** — Multi-AD node placement via `node_placement_ads` at zero extra cost; easy scaling within free tier limits
- **Databases Included** — Optional Always-Free MySQL HeatWave and ATP Autonomous Database modules
- **SSH Access** — Optional SSH key injection into worker nodes for direct access via Bastion/VPN
- **Parameterized** — Typed variables, validation, and clear configuration

📖 **See [Complete Always Free Resources Guide](docs/ALWAYS-FREE-RESOURCES.md)** for detailed quota information

---

## 📋 Prerequisites

1. **Oracle Cloud Account** — Free-tier account with Always-Free resources enabled
2. **Terraform** — v1.0+ installed locally
3. **OCI CLI** — For retrieving kubeconfig credentials
4. **SSH keypair** (optional) — For worker node access

---

## 🚀 Quick Start

📖 **See [Quick Start Guide](docs/QUICK-START.md)** for step-by-step deployment instructions.

---

## 🔐 Security Architecture

📖 **See [Security Architecture Guide](docs/SECURITY-ARCHITECTURE.md)** for details on the private API endpoint, access methods (Bastion, VPN), Network Security Lists, encryption, and multi-AD node placement.

---

## 📊 Monitoring & Observability

### VCN Flow Logs (Always-Free: 10 GB/month)

View network traffic flowing through the cluster:

```bash
# Query flow logs in OCI Console → Logging → Logs
# Useful for troubleshooting and security investigations
oci logging log-content get \
  --log-id <log-id-from-outputs> \
  --log-group-id <log-group-id-from-outputs>
```

---

## 🚢 Example App

After provisioning your cluster, deploy a ready-made nginx example to validate end-to-end networking and ingress:

```bash
kubectl apply -f examples/app/
kubectl rollout status deployment/example-app -n example-app
```

The example exercises the full stack: Pod → Service → Ingress → OCI Flexible Load Balancer. It uses `nginx:stable-alpine` which is compatible with the ARM-based `VM.Standard.A1.Flex` nodes.

📖 **See [examples/app/README.md](examples/app/README.md)** for full deploy, verify, and teardown instructions.

---

## 🛠️ Access Guide

📖 **See [Access Guide](docs/ACCESS-GUIDE.md)** for detailed instructions on:
- 🛠️ Accessing the Kubernetes Cluster (generating Kubeconfig)
- 🖥️ Accessing Worker Nodes (using Bastion or SSH)
- 🗄️ Accessing the Database (connecting to MySQL HeatWave)

---

## �💰 Cost Estimation

**All Always-Free services:**

| Resource                   | Always Free Quota        | This Project Uses        | Cost   |
| -------------------------- | ------------------------ | ------------------------ | ------ |
| OKE Cluster (Basic)        | 1 cluster                | 1 cluster                | $0     |
| A1 Compute (Ampere ARM)    | 4 OCPU + 24 GB RAM total | 4 × 1 OCPU (6 GB each)   | $0     |
| Block Storage              | 200 GB total             | ~120 GB (boot volumes)   | $0     |
| VCN + Subnets              | Included                 | 1 VCN, 4 subnets         | $0     |
| Public IP Addresses        | Included                 | 1 (load balancer subnet) | $0     |
| Load Balancer              | 1 ALB **OR** 1 NLB       | Optional (for ingress)   | $0     |
| Outbound Data Transfer     | 10 TB/month              | ~1-10 GB/month           | $0     |
| VCN Flow Logs              | 10 GB/month              | Enabled (monitoring)     | $0     |
| Logging                    | 10 GB ingestion/month    | ~1-5 GB/month            | $0     |
| Bastion Service            | Up to 5 bastions         | Optional (SSH to nodes)  | $0     |
| MySQL HeatWave DB System   | 1 ECPU, 50GB Storage     | Optional                 | $0     |
| MySQL HeatWave Cluster     | 1 Node, 16GB Memory      | Optional                 | $0     |
| Monitoring & Notifications | Included                 | Basic metrics            | $0     |
| **Total Monthly Cost**     | **—**                    | **—**                    | **$0** |

### Optional Add-ons (Additional Costs)

| Resource                              | Cost                     | When Needed              |
| ------------------------------------- | ------------------------ | ------------------------ |
| Additional A1 compute (beyond 4 OCPU) | ~$0.01/OCPU-hour         | Scaling beyond free tier |
| Block storage (beyond 200 GB)         | ~$0.0255/GB-month        | Large persistent volumes |
| Enhanced OKE cluster (vs Basic)       | ~$0.10/hour (~$73/month) | Advanced K8s features    |

### Always Free Resources NOT Used

These are available if you want to extend the setup:

- **2 × Oracle Autonomous Databases** (20 GB each, ATP or ADW)
- **2 × VM.Standard.E2.1.Micro** (AMD x86 instances)
- **10 GB Object Storage** (for backups/artifacts)
- **10 GB Archive Storage** (long-term retention)
- **5 × OCI Bastion Service** instances (for SSH to private resources)

**Note:** Always Free resources verified from https://www.oracle.com/cloud/free/ (Feb 2026)

📖 **See [docs/ALWAYS-FREE-RESOURCES.md](docs/ALWAYS-FREE-RESOURCES.md)** for complete Always Free tier details and verification commands.

---

## 🛠️ Development & Contributing

### CI/CD

This project uses GitHub Actions for automated linting and validation:
- **Terraform Format Check**: Ensures idiomatic code style
- **Terraform Validate**: Checks for configuration validity
- **TFLint**: Catches provider-specific issues and best practices

### Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) and our [Code of Conduct](CODE_OF_CONDUCT.md).

## 🗑️ Cleanup

```bash
terraform destroy
```

---

## 📝 Configuration Options

📖 **See [Configuration Guide](docs/CONFIGURATION.md)** for details on the `terraform.tfvars` options and variable validation.

---

## 🚨 Important Notes

### Free Tier Constraints

- **A1 Compute**: 3,000 OCPU-hours/month shared. A 1-OCPU instance runs ~125 days (3000 hrs/month ÷ 4 nodes ÷ 24 hrs/day).
- **Network**: 10 TB outbound data transfer/month (per tenancy), VCN Flow Logs shared quota.
- **Scale carefully** — Adding nodes exceeds free tier and incurs charges.

### Security Best Practices

1. **Keep API private** — Enable public only for development with strict IP allowlists.
2. **Use VPN for production** — Site-to-Site VPN is free and secure.
3. **Monitor flow logs** — Review VCN Flow Logs regularly for unauthorized access attempts.
4. **Implement RBAC** — Kubernetes RBAC is your responsibility; configure serviceaccounts and roles.
5. **Patch regularly** — Update Kubernetes and node images through OKE console.

---

## 📖 References

- [OCI Always-Free Services](https://www.oracle.com/cloud/free/)
- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [OCI VCN & Networking](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [VPN Site-to-Site Setup](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/settingupipsecvpn.htm)
- [OCI Logging & OCI Audit](https://docs.oracle.com/en-us/iaas/Content/Logging/home.htm)

---

## 🤝 Contributing

Found issues or enhancements? Please open an issue or PR.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
