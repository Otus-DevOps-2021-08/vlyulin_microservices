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
  # �������� ����������
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  # �������� ����������
  description = "Path to the private key used for ssh access"
}
variable service_account_key_file {
  description = "key.json"
}
variable required_master_instances {
  description = "Required number of instances"
  default     = 1
}
variable required_worker_instances {
  description = "Required number of instances"
  default     = 1
}
variable disk_image_id {
  description = "Disk image"
  type = string
}
variable master-tags {
  description = "Master virtual machine tags"
  type = string
}
variable worker-tags {
  description = "Worker virtual machine tags"
  type = string
}
variable disk_size {
  description = "Disk size"
  type        = number
  default     = 50
}
variable master-public-ip-address {
  description = ""
  type        = string
}
