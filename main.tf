terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc10"
      # version = ">=2.9.6"
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

  # efidisk (and its secure boot keys) is inherited from the UEFI template, not managed here
  bios    = var.uefi ? "ovmf" : "seabios"
  machine = var.uefi ? "q35" : null

  agent = 1
  skip_ipv6 = true
  power_state = "running"

  startup_shutdown {
    order            = -1
    shutdown_timeout = -1
    startup_delay    = -1
  }

  # rhel 9 needs x86-64-v2 or newer and kernel panics on kvm64
  cpu {
    cores   = var.proxmox_cores
    sockets = var.proxmox_sockets
    type    = var.proxmox_cpu_type
  }
  memory  = var.proxmox_memory
  scsihw = "virtio-scsi-pci"

  ciuser = var.proxmox_cloud_init_user
  cipassword = var.proxmox_cloud_init_user_password
  sshkeys    = var.ssh_public_keys
  ciupgrade  = var.proxmox_ciupgrade

  os_type = "cloud-init"
  ipconfig0   = count.index < length(var.static_ip_addresses) ? "ip=${var.static_ip_addresses[count.index]}/${var.static_ip_netmask},gw=${var.static_ip_gateway}" : "ip=dhcp"


  # the provider removes any drive not declared here, so the template's cloud-init drive must be listed.
  # disks are compared by position and proxmox returns them sorted by slot, so keep ide0 before scsi0
  disk {
    type    = "cloudinit"
    slot    = "ide0"
    storage = var.proxmox_storage_pool
  }

  disk {
    size    = var.proxmox_disk_space
    type    = "disk"
    slot    = "scsi0"
    storage = var.proxmox_storage_pool
    format  = "raw"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.proxmox_network
  }

  # the templates have serial0 for the xterm.js console; like drives, undeclared devices are removed
  serial {
    id   = 0
    type = "socket"
  }

  # the templates grow the root disk on first boot via a cloud-init per-instance script, so no ssh provisioning is needed
}
