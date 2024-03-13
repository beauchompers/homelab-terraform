terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=2.9.6"
    }
  }
}
provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
  pm_tls_insecure = var.proxmox_tls_insecure
  pm_parallel     = 1
}
resource "proxmox_vm_qemu" "proxmox_vm" {
  count       = var.vm_count
  name        = "${var.vm_prefix}0${count.index + 1}"
  target_node = var.proxmox_node

  clone = var.proxmox_template_name
  full_clone = true

  agent = 1

  cores   = var.proxmox_cores
  sockets = var.proxmox_sockets
  memory  = var.proxmox_memory
  scsihw = "virtio-scsi-pci"

  ciuser = var.proxmox_cloud_init_user
  cipassword = var.proxmox_cloud_init_user_password

  os_type = "cloud-init"

  disk {
    size    = var.proxmox_disk_space
    type    = "scsi"
    storage = var.proxmox_storage_pool
  }

  network {
    model  = "virtio"
    bridge = var.proxmox_network
  }

  connection {
      type     = "ssh"
      user     = var.proxmox_cloud_init_user
      password = var.proxmox_cloud_init_user_password
      host     = self.ssh_host
  }
  
  provisioner "file" {
    source = "files/resize_disk.sh"
    destination = "/tmp/resize_disk.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo cloud init done",
      "sudo chmod +x /tmp/resize_disk.sh",
      "sudo /tmp/resize_disk.sh",
      "sudo shutdown -r +1"
    ]
  }
}
