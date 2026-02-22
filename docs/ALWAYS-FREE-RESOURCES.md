# OCI Always Free Resources Guide

Oracle Cloud Infrastructure (OCI) offers a generous Always Free tier. This project is specifically designed to fit within these constraints while providing a functional Kubernetes cluster.

## 🚀 Compute (Ampere A1)

- **Total Quota:** 4 OCPUs and 24 GB of RAM.
- **Project Usage:** 4 nodes, each with 1 OCPU and 6 GB RAM.
- **Constraint:** This is a monthly quota of 3,000 OCPU hours and 18,000 GB hours. Running 4 OCPUs continuously for a month uses approximately 2,880 - 2,976 OCPU hours, staying just within the limit.
- **Multi-AD placement:** Worker nodes may be spread across multiple availability domains using `node_placement_ads` without affecting the Always-Free quota — the quota is a tenancy-wide OCPU/RAM pool, not per-AD. Intra-VCN cross-AD traffic is not charged.

## 📦 Storage

- **Block Volume:** 200 GB total Always Free.
- **Boot Volumes:** Each A1 node requires a boot volume (default 46.5 GB). 4 nodes = ~186 GB.
- **Persistent Volumes:** Remaining space (~14 GB) can be used for small K8s PersistentVolumes (PVs).
- **Object Storage:** 20 GB Always Free (Standard and Archive).

## 🌐 Networking

- **VCNs:** Up to 2 Virtual Cloud Networks.
- **Load Balancers:** 1 Always Free Application Load Balancer (Flexible, 10 Mbps) **AND** 1 Always Free Network Load Balancer.
- **Data Transfer:** 10 TB outbound data transfer per month.
- **Public IPs:** 2 public IPv4 addresses.

## 🗄️ Databases

- **MySQL HeatWave:** 1 Always Free MySQL HeatWave DB System (1 ECPU, 50GB storage) and 1 HeatWave Cluster (1 Node, 16GB Memory). Enable with `create_mysql_heatwave = true`.
- **Autonomous Database:** 2 Always Free Autonomous Databases (ADW or ATP, up to 20 GB storage each). Enable with `create_autonomous_database = true` to provision 1 Always-Free ATP instance. ⚠️ Provisioning a third ADB instance in the same tenancy will exceed the free-tier quota and incur charges.

## ☸️ Managed Kubernetes (OKE)

- **Cluster Fee:** OKE **Basic** clusters have no cluster management fee.
- **Worker Nodes:** Standard A1 Compute pricing applies (which is $0 within the Always Free limits).

## 🔍 Observability & Others

- **Logging:** 10 GB of log ingestion per month.
- **Monitoring:** 500 million ingestion data points, 1 billion retrieval data points per month.
- **Notifications:** 1 million per month via HTTPS, 1,000 per month via Email.
- **Bastion Service:** 5 Bastions total.

## ⚠️ Important Considerations

1. **Regional Availability:** Always Free A1 resources are in high demand and might not be available in all regions or all ADs at all times.
2. **Account Status:** Your account must be in "Active" status. If your trial ends, make sure your resources are tagged as "Always Free" or they might be terminated.
3. **Reclaiming Idle Resources:** Oracle may reclaim idle Always Free compute instances. Keeping your K8s nodes active with workloads helps prevent this.

---
*Verified as of February 2026. For latest details, see [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/).*
