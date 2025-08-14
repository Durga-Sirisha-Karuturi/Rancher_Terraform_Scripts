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
}

provider "rancher2" {
  api_url   = var.rancher_url
  token_key = var.rancher_token
  insecure  = true # set to false if using valid certs
}

resource "rancher2_cluster" "custom_cluster" {
  name        = "${var.cluster_name}"
}


locals {
  base_command = rancher2_cluster.custom_cluster.cluster_registration_token.0.insecure_command
}

# 2. SSH into each VM and run the command
resource "null_resource" "register_nodes" {

  provisioner "remote-exec" {
    inline = [
      "echo '${var.ssh_password}' | sudo -S sh -c '${replace(local.base_command, "'", "'\"'\"'")}'"
    ]

    connection {
      type     = "ssh"
      host     = var.vms
      user     = var.ssh_user
      password = var.ssh_password
    }
  }
}

output "base_registration_command" {
  value     = local.base_command
  sensitive = false
}
