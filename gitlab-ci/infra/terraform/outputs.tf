output "internal_ip_address_app" {
  value = "${yandex_compute_instance.gitlab-ci[*].network_interface.0.ip_address}"
}
