terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zones[var.zone]
}

resource "yandex_kubernetes_cluster" "cluster" {
  name                    = "terraform-k8s"
  description             = "Created by kubernates"
  folder_id               = var.folder_id
  network_id              = var.network_id
  service_account_id      = var.k8s_service_account_id
  node_service_account_id = var.k8s_service_account_id
  release_channel         = "RAPID"

  master {
    version   = "1.19"
    public_ip = true

    zonal {
      zone      = var.zones[var.zone]
      subnet_id = var.subnet_id
    }
  }
}

resource "yandex_kubernetes_node_group" "node_groups" {

  cluster_id  = yandex_kubernetes_cluster.cluster.id
  name        = "terraform-k8s-node-grp"
  description = "Kubernetes node group created by terraform"
  version     = "1.19"

  instance_template {
    platform_id = "standard-v2"
    network_interface {
       nat         = true
       subnet_ids         = [var.subnet_id]
    }
    metadata = {
      ssh-keys = "ubuntu:${file(var.public_key_path)}"
    }
    resources {
      cores         = 4
      core_fraction = 100
      memory        = 4
    }
    boot_disk {
      size = 64
      type = "network-ssd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }
}
