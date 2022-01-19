output "internal_ip_address_master" {
  value = "${yandex_compute_instance.master-host[*].network_interface.0.ip_address}"
}

output "public_ip_address_master" {
  value = "${yandex_compute_instance.master-host[*].network_interface.0.nat_ip_address}"
}

output "internal_ip_address_worker" {
  value = "${yandex_compute_instance.worker-host[*].network_interface.0.ip_address}"
}

output "public_ip_address_worker" {
  value = "${yandex_compute_instance.worker-host[*].network_interface.0.nat_ip_address}"
}
