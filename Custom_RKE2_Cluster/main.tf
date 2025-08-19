terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    rancher2 = {
      source  = "rancher/rancher2"
    }
  }
}

variable "rancher_url" {}
variable "rancher_token" {
  sensitive = true
}
variable "cluster_name" {}
variable "ssh_user" {}
variable "ssh_password" {
  sensitive = true
}
variable "vms" {
  type = list(object({
    ip    = string
    roles = list(string)
  }))
}

provider "rancher2" {
  api_url   = var.rancher_url
  token_key = var.rancher_token
  insecure  = true # set to false if using valid certs
}

resource "rancher2_cluster_v2" "custom_cluster" {
  name               = var.cluster_name
  kubernetes_version = "v1.32.6+rke2r1"

  rke_config {
    machine_global_config = <<EOF
cni: "canal"
EOF
  }
}


locals {

  base_command = rancher2_cluster_v2.custom_cluster.cluster_registration_token.0.insecure_node_command

  role_flag_map = {
    controlplane = "--controlplane"
    etcd         = "--etcd"
    worker       = "--worker"
  }

  node_commands = {
    for idx, vm in var.vms :
    idx => join(" ", [
      local.base_command,
      join(" ", [for r in vm.roles : lookup(local.role_flag_map, r, "")])
    ])
  }
}


# 2. SSH into each VM and run the command
resource "null_resource" "register_nodes" {
  for_each = { for idx, vm in var.vms : idx => vm }

  provisioner "remote-exec" {
    inline = [
      "echo '${var.ssh_password}' | sudo -S sh -c '${replace(local.node_commands[each.key], "'", "'\"'\"'")}'",
      <<-EOC
      if echo "${join(" ", each.value.roles)}" | grep -q "controlplane"; then
        echo '${var.ssh_password}' | sudo -S ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl
        export PATH=$PWD/bin:$PATH
        echo "export PATH=$PATH:/var/lib/rancher/rke2/bin" >> $HOME/.bashrc
        echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml"  >> $HOME/.bashrc
        source ~/.bashrc

      fi
      EOC
    ]

    connection {
      type     = "ssh"
      host     = each.value.ip
      user     = var.ssh_user
      password = var.ssh_password
    }
  }
}

output "base_registration_command" {
  value     = local.node_commands
  sensitive = true
}
