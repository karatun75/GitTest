#!/bin/bash
# 1

ping 8.8.8.8

ls /dev/nvme*
ls /dev/sd*

lsblk

blkid

gdisk /dev/nvme0n1
# mklabel gpt 
# mkpart ESP fat32 1MiB 512MiB 
# set 1 boot on 
# mkpart primary
# Теперь можем настроить шифрование на втором диске:
n


cryptsetup luksFormat /dev/nvme0n1p4

cryptsetup open /dev/nvme0n1p4 luks

# пароль  "luks"

ls /dev/mapper/*

# сделать группу "Volume group". И в группе создать логические разделы "Logical volume":

pvcreate /dev/mapper/luks
vgcreate steel /dev/mapper/luks
lvcreate -L 20G steel -n swap
lvcreate -L 120G steel -n root
lvcreate -l 100%FREE steel -n home

lvs

# $ lvs  LV   VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert  
# root steel      -wi-a----- 120g  
# swap steel      -wi-a-----  20.00g
# home steel      -wi-a----- 108.72g

# Форматируем разделы

mkfs.ext4 /dev/mapper/steel-root
mkfs.ext4 /dev/mapper/steel-home
mkswap /dev/mapper/steel-swap

# $ mkfs.fat -F32 /dev/nvme0n1p1

# Монтируем

mount /dev/mapper/steel-root /mnt
mkdir -p /mnt/{home,boot/efi}
mount /dev/nvme0n1p1 /mnt/boot/efi
mount /dev/mapper/steel-home /mnt/home
swapon /dev/mapper/steel-swap


# Зеркала устанавливаем

nano /etc/pacman.d/mirrorlist

Server=http//mirrors.prok.pw/archlinux/$repo/os/$arch

# Устанавливаем

pacstrap -i /mnt base base-devel linux linux-firmware lvm2 vim dhcpcd net-tools iproute2 networkmanager os-prober mtools fuse tmux links wget git
 

# Генерируем fstab

genfstab -U /mnt >> /mnt/etc/fstab

cat /mnt/etc/fstab

arch-chroot /mnt



