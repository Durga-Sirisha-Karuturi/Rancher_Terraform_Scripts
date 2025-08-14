cluster_name  = "custom-cluster"
rancher_token = "token-gbt44:nxr4v5nb5sh9sgwc225rjbnpzl2x4984bzxnls495d66xtbflx46v9"
rancher_url   = "https://100.64.188.230.sslip.io"
ssh_password  = "p@SSW0RD@1234"
ssh_user      = "sifyadm"

vms = [
  {
    ip    = "100.64.188.228"
    roles = ["controlplane", "etcd", "worker"]
  }
]
