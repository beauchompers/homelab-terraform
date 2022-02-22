variable "proxmox_host" {
  type        = string
  description = "the hostname or ip of the proxmox host"
}
variable "proxmox_node" {
  type        = string
  description = "proxmox node name"
}
variable "proxmox_user" {
  type        = string
  description = "username for the proxmox api"
  default     = "terraform@pam"
}
variable "proxmox_password" {
  type        = string
  description = "password for the proxmox user"
  sensitive   = true
}
variable "proxmox_tls_insecure" {
  type        = bool
  description = "disable tls check"
  default     = true
}
variable "proxmox_template_name" {
  type        = string
  description = "name of the proxmox template to clone"
}
variable "vm_prefix" {
  type        = string
  description = "prefix of the vm(s)"
  default     = "proxmox-vm-"
}
variable "vm_count" {
  type        = number
  description = "number of vms to create"
  default     = 1
}
variable "proxmox_cores" {
  type        = number
  description = "number of cores to assign"
  default     = 1
}
variable "proxmox_sockets" {
  type        = number
  description = "number of sockets to assign"
  default     = 1
}
variable "proxmox_memory" {
  type        = number
  description = "amount of memory to assign in MB"
  default     = 2048
}
variable "proxmox_cloud_init_user" {
  type        = string
  description = "user to create via cloud-init"
}
variable "proxmox_cloud_init_user_password" {
  type        = string
  description = "password for the cloud-init user"
  sensitive   = true
}
variable "proxmox_storage_pool" {
  type        = string
  description = "storage pool on the proxmox node"
  default     = "local-lvm"
}
variable "proxmox_disk_space" {
  type        = string
  description = "amount of storage to assign"
  default     = "10G"
}