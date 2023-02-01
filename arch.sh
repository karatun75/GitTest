#!/bin/bash
# 1
if
echo "ping -c17 8.8.8.8"

# ls /dev/nvme*
# ls /dev/sd*

echo "lsblk"

echo "blkid"

echo "gdisk /dev/nvme0n1"
# mklabel gpt 
# mkpart ESP fat32 1MiB 512MiB 
# set 1 boot on 
# mkpart primary
# Теперь можем настроить шифрование на втором диске:
# n


echo "cryptsetup luksFormat /dev/nvme0n1p4"

echo "cryptsetup open /dev/nvme0n1p4 luks"

# пароль  "luks"

echo "ls /dev/mapper/*"

# сделать группу "Volume group". И в группе создать логические разделы "Logical volume":

echo "pvcreate /dev/mapper/luks"
echo "vgcreate steel /dev/mapper/luks"
echo "lvcreate -L 20G steel -n swap"
echo "lvcreate -L 120G steel -n root"
echo "lvcreate -l 100%FREE steel -n home"

echo "lvs"

# $ lvs  LV   VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert  
# root steel      -wi-a----- 120g  
# swap steel      -wi-a-----  20.00g
# home steel      -wi-a----- 108.72g

# Форматируем разделы

echo "mkfs.ext4 /dev/mapper/steel-root"
echo "mkfs.ext4 /dev/mapper/steel-home"
echo "mkswap /dev/mapper/steel-swap"

# $ mkfs.fat -F32 /dev/nvme0n1p1

# Монтируем

echo "mount /dev/mapper/steel-root /mnt"
echo "mkdir -p /mnt/{home,boot/efi}"
echo "mount /dev/nvme0n1p1 /mnt/boot/efi"
echo "mount /dev/mapper/steel-home /mnt/home"
echo "swapon /dev/mapper/steel-swap"


# Зеркала устанавливаем
echo "Server=http://mirrors.prok.pw/archlinux/$repo/os/$arch >> /etc/pacman.d/mirrorlist"
nano /etc/pacman.d/mirrorlist

# Server=http://mirrors.prok.pw/archlinux/$repo/os/$arch

# Устанавливаем

echo "pacstrap -i /mnt base base-devel linux linux-firmware lvm2 vim dhcpcd net-tools iproute2 networkmanager os-prober mtools fuse tmux links wget git"
 

# Генерируем fstab

echo "genfstab -U /mnt >> /mnt/etc/fstab"

echo "cat /mnt/etc/fstab"

echo "arch-chroot /mnt"

fi



