terraform {
   backend "s3" {
    bucket = "my-k3s"
    key = "terraform.tfstate"
    endpoint = "https://truenas.local.lan:9000"
    region="us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
    }

  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.14"
    }

    macaddress = {
      source = "ivoronin/macaddress"
      version = "0.3.0"
    }
  }
}

provider proxmox {
  pm_log_enable = true
  pm_log_file = "terraform-plugin-proxmox.log"
  pm_debug = true
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
  }

  ## TODO: Update these for your specific setup
  pm_tls_insecure = true
  pm_api_url = "https://pve1.local.lan:8006/api2/json"
  pm_user = "root@pam"
  pm_password = var.proxmox_password
  pm_otp = ""
}
/*
module "k3s" {
  source  = "github.com/trevor-crowley/terraform-proxmox-k3s.git"
  cluster_name = "k3s"
  authorized_keys_file = var.public_keys

  proxmox_node = "pve1"

  node_template = "Ubuntu-22.04.3-LTS-k3s"
  proxmox_resource_pool = "my-k3s"

  network_gateway = "192.168.99.1"
  lan_subnet = "192.168.99.0/24"

  support_node_settings = {
    cores = 2
    memory = 4096
  }

  master_nodes_count = 2
  master_node_settings = {
    cores = 2
    memory = 4096
  }

  # 192.168.0.200 -> 192.168.0.207 (6 available IPs for nodes)
  control_plane_subnet = "192.168.99.200/29"

  node_pools = [
    {
      name = "worker"
      storage_id = "local2-lvm"
      disk_size = "80G"
      size = 2
      # 192.168.0.208 -> 192.168.0.223 (14 available IPs for nodes)
      subnet = "192.168.99.208/29"
    }
  ]
}
*/
module "rancher_k3s" {
  source  = "github.com/trevor-crowley/terraform-proxmox-k3s.git"
  cluster_name = "rancher"
  authorized_keys_file = var.public_keys

  proxmox_node = "pve1"

  node_template = "Ubuntu-22.04.3-LTS-k3s"
  proxmox_resource_pool = "my-k3s"

  network_gateway = "192.168.99.1"
  lan_subnet = "192.168.99.0/24"

  support_node_settings = {
    cores = 2
    memory = 4096
  }

  master_nodes_count = 2
  master_node_settings = {
    cores = 2
    memory = 4096
    disk_size = "10G"
  }

  # 192.168.0.200 -> 192.168.0.207 (6 available IPs for nodes)
  control_plane_subnet = "192.168.99.216/29"

 node_pools = [
    {
      name = "worker"
      storage_id = "local-lvm"
      disk_size = "10G"
      size = 2
      # 192.168.0.208 -> 192.168.0.223 (14 available IPs for nodes)
      subnet = "192.168.99.224/29"
    }
  ]
}

/*
output "kubeconfig" {
  value = module.k3s.k3s_kubeconfig
  sensitive = true
}
*/
output "kubeconfig_rancher" {
  value = module.rancher_k3s.k3s_kubeconfig
  sensitive = true
}

