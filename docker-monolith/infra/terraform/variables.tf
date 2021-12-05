variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable subnet_id {
  description = "Subnet id"
}
variable region_id {
  description = "region"
  default     = "ru-central1"
}
variable "zones" {
  type = map
  default = {
    "a" = "ru-central1-a"
    "b" = "ru-central1-b"
    "c" = "ru-central1-c"
  }
}
variable zone {
  description = "Selected zone"
  type        = string
  default     = "a"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}
variable service_account_key_file {
  description = "key.json"
}
variable required_number_instances {
  description = "Required number of instances"
  default     = 2
}
variable disk_image {
  description = "Disk image for reddit app"
  default     = "ubuntu-with-docker"
}
