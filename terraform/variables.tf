variable "vm_count" {
  description = "Number of VMs"
  default     = 4
}

variable "network_cidr_ceph_admin" {
  default = "192.168.100.0/24"
}

variable "network_cidr_ceph_cluster" {
  default = "192.168.101.0/24"
}

variable "ssh_key_path" {
  description = "Path to the SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "image_source" {
  description = "The source URL for the image"
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
