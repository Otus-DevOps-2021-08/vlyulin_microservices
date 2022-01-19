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

resource "yandex_compute_instance" "master-host" {
  # count       = var.required_master_instances
  # name        = "${var.master-tags}-${count.index}"
  name        = "${var.master-tags}"
  platform_id = "standard-v2"

  metadata = {
    ssh-keys = "yc-user:${file(var.public_key_path)}"
  }

  labels = {
    tags = var.master-tags
  }

  resources {
    cores         = 4
    memory        = 4
    core_fraction = 5
  }

  boot_disk {
   initialize_params {
     image_id = var.disk_image_id
     size     = var.disk_size
     type     = "network-ssd"
   }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    # nat_ip_address = "${var.master-public-ip-address}"
    nat       = true
  }

  connection {
      type  = "ssh"
      user  = "ubuntu"
      agent = false
      host  = self.network_interface.0.nat_ip_address
      # путь до приватного ключа
      private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    # Install Python for Ansible
    inline = ["echo Hi!"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.network_interface.0.nat_ip_address},' ../ansible/playbooks/install-kubernetes.yml --extra-vars 'master-ip=${self.network_interface.0.nat_ip_address}'"
  }

  # provisioner "local-exec" {
  #  command = "ansible-playbook -u ubuntu -i '${self.network_interface.0.nat_ip_address},' ../ansible/playbooks/cluster-init.yml --extra-vars masterip='${self.network_interface.0.nat_ip_address}'"
  #  # command = "ansible-playbook -u ubuntu -i '${local.master_id},' ../ansible/playbooks/cluster-init.yml --extra-vars masterip='${local.master_id}'"
  # }

  # lifecycle {
  #  prevent_destroy = true 
  # }
}

resource "yandex_compute_instance" "worker-host" {
  count       = var.required_worker_instances
  name        = "${var.worker-tags}-${count.index}"
  platform_id = "standard-v2"

  metadata = {
    ssh-keys = "yc-user:${file(var.public_key_path)}"
  }

  labels = {
    tags = var.worker-tags
  }

  resources {
    cores         = 4
    memory        = 4
    core_fraction = 5
  }

  boot_disk {
   initialize_params {
     image_id = var.disk_image_id
     size     = var.disk_size
     type     = "network-ssd"
   }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  connection {
      type  = "ssh"
      user  = "ubuntu"
      agent = false
      host  = self.network_interface.0.nat_ip_address
      # путь до приватного ключа
      private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    # Install Python for Ansible
    inline = ["echo Hi!"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.network_interface.0.nat_ip_address},' ../ansible/playbooks/install-kubernetes.yml"
  }

  # lifecycle {
  #  prevent_destroy = true 
  # }
}

locals {
  master_id  = toset(yandex_compute_instance.master-host.*.network_interface.0.nat_ip_address)
  workers_ids = toset(yandex_compute_instance.worker-host.*.network_interface.0.nat_ip_address)
  # workers_ids = join("_", yandex_compute_instance.worker-host.*.network_interface.0.nat_ip_address )
}

# resource "null_resource" "workers-init" {
#
#  depends_on = [yandex_compute_instance.master-host, yandex_compute_instance.worker-host]
#  # count      = length( yandex_compute_instance.worker-host )
#  # instance   = split("_", local.workers_ids)[count.index]
#
#  for_each = local.workers_ids
#  # triggers = {
#  #   list_value_ip = each.value
#  # }
#
#  connection {
#      type  = "ssh"
#      host  = each.value
#      user  = "ubuntu"
#      agent = false
#      # путь до приватного ключа
#      private_key = file(var.private_key_path)
#    }
#
#  provisioner "remote-exec" {
#    # Install Python for Ansible
#    inline = ["echo Hi!"]
#  }
#
#  provisioner "local-exec" {
#    command = "ansible-playbook -u ubuntu -i '${each.value},' ../ansible/playbooks/worker-init.yml"
#  } 
#}
