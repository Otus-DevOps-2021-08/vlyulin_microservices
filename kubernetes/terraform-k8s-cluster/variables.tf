variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable region_id {
  description = "region"
  default     = "ru-central1"
}
variable network_id {
  description = "Folder"
}
variable subnet_id {
  description = "Subnet"
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
  description = "key .json"
}
variable required_number_instances {
  description = "Required number of instances"
  default     = 1
}
variable required_db_number_instances {
  description = "Required db number of instances"
  default     = 1
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-db-base"
}
variable k8s_service_account_id {
}