#!/bin/sh

# fdisk -l /dev/sda | grep ^/dev
sgdisk --move-second-header /dev/sda
parted -s /dev/sda 'resizepart 3 100%'
pvresize /dev/sda3
lvresize --extents +100%FREE --resizefs /dev/mapper/ubuntu--vg-ubuntu--lv
