# Terraform Rancher Cluster Automation

This repository contains Terraform configurations for automating Rancher cluster management in two scenarios:
1. **Custom RKE2 Cluster Creation** – Creates a new RKE2 cluster in Rancher and automatically registers nodes.
2. **Imported Cluster Registration** – Imports an existing Kubernetes cluster into Rancher.

📌 **1. Custom RKE2 Cluster Creation**

**Overview**

This configuration:
 
- Creates a new RKE2 custom cluster in Rancher.
- Retrieves the node registration command.
- SSHs into target VMs to run the command with assigned roles (controlplane, etcd, worker).
- Configures kubectl automatically on controlplane nodes.

**Prerequisites**

- Rancher running with valid API token.
- SSH access to all VMs (user + password).
- VMs prepared for RKE2.

📌 **2. Imported Cluster Registration**

**Overview**

This configuration:

- Creates an Imported Cluster in Rancher.
- Retrieves the cluster registration command.
- SSHs into the target VM and executes the registration command to connect it to Rancher.

**Prerequisites**

- Existing Kubernetes cluster running on target node(s).
- Rancher with valid API token.
- SSH access to target VM(s).

**Configuration (terraform.tfvars)**

cluster_name – Name of the cluster as it will appear in Rancher.  
rancher_token – Rancher API token for authentication.  
rancher_url – Rancher server URL ].  
ssh_user / ssh_password – Credentials for SSH access to your VMs.  
vms – For custom clusters, a list of objects with ip and roles; for imported clusters, a single VM IP.  

Roles can be controlplane, etcd, worker, or a combination.  

**Roles Reference**  
- controlplane – API server
- etcd – Kubernetes state storage  
- worker – Runs workloads


**🚀 Usage (Both Setups)**

1. **Initialize Terraform**  
terraform init  

2. **Validate**  
terraform validate  

3. **Plan**  
terraform plan -var-file="terraform.tfvars"  

4. **Apply**  
terraform apply -var-file="terraform.tfvars"  

**📤 Outputs**  
base_registration_command – Displays the Rancher registration command executed on each VM.

