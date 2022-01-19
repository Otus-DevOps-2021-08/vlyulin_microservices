provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zones[var.zone]
}

resource "yandex_compute_instance" "gitlab-ci" {
  count       = var.required_number_instances
  name        = "${var.tags}-${count.index}"
  platform_id = "standard-v2"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  labels = {
    tags = var.tags
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }

  boot_disk {
   initialize_params {
     image_id = var.disk_image_id
     size = var.disk_size
   }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }
}
