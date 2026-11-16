# Terraform - Proxmox Homelab

Quick Terraform plan to create Proxmox VMs in my homelab, cloned from the templates built in `homelab-packer`.

```
terraform workspace select <name>   # one workspace per tfvars file
terraform apply -var-file=<name>.tfvars
```

## Templates

| VMID | Template name | Firmware | Use with |
|---|---|---|---|
| 300 | `packer-ubuntu-2204` | SeaBIOS | `uefi = false` |
| 301 | `packer-ubuntu-2204-uefi` | OVMF + Secure Boot | `uefi = true` |
| 400 | `packer-ubuntu-2404` | SeaBIOS | `uefi = false` |
| 401 | `packer-ubuntu-2404-uefi` | OVMF + Secure Boot | `uefi = true` |
| 500 | `packer-rhel-98` | SeaBIOS | `uefi = false` |
| 501 | `packer-rhel-98-uefi` | OVMF + Secure Boot | `uefi = true` |

The templates have a 20G disk, so `proxmox_disk_space` must be at least `20G`. Larger disks are grown on first
boot by a cloud-init per-instance script baked into the template, so no SSH provisioning is needed.

## Variables worth knowing

| Variable | Default | Notes |
|---|---|---|
| `proxmox_template_name` | | template to clone, see above |
| `uefi` | `false` | must match the template's firmware |
| `proxmox_disk_space` | `20G` | minimum 20G |
| `proxmox_cpu_type` | `x86-64-v2-AES` | RHEL 9 needs x86-64-v2 or newer, `host` also works |
| `proxmox_ciupgrade` | `false` | first-boot package upgrade, fails on unregistered RHEL clones |
| `ssh_public_keys` | `null` | keys for the cloud-init user, one per line |
| `static_ip_addresses` | `[]` | static IPs per VM, the rest use DHCP. needs `static_ip_gateway` |
