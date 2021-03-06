﻿#!/bin/sh
#Воспользовался материалом  в личных целях
#Author Mikhail Sarvilin
#script for install Arch Linux 
#
#
mkfs.ext2 /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.btrfs /dev/sda3 -L root
mkfs.btrfs /dev/sda4 -L home
mount /dev/sda3 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
mount -t proc /proc /mnt/proc
mount --rbind /sys /mnt/sys
mount --rbind /dev /mnt/dev
echo "Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch" > /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel grub net-tools links wget reflector
arch-chroot /mnt pacman -S netctl dialog wpa_supplicant --noconfirm --noprogressbar --quiet
genfstab -pU /mnt >> /mnt/etc/fstab
arch-chroot /mnt
nano /etc/fstab
echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "en_US.UTF-8" > /etc/locale.conf
nano /etc/mkinitcpio.conf
mkinitcpio -p linux
nano /etc/hostname
nano /etc/hosts
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
passwd
echo -e "[multilib]i\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
useeradd -m -g users -G audio,games,lp,optical,power,scanner,storage,video,wheel -s /bin/bash tux
passwd tux
systemctl enable dhcpcd
systemctl start dhcpcd
wifi-menu
reflector -l 3 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syu
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
pacman -S xorg-server xorg-xinit xorg-apps mesa-libgl lib32-mesa-libgl xterm xorg-drivers xf86-input-synaptics --noconfirm --noprogressbar --quiet
X -configure
pacman -S i3 sddm alsa-utils --noconfirm --noprogressbar --quiet
systemctl enable sddm.service
amixer sset Master unmut
amixer sset 'Master' 50%
pacman -S ttf-liberation ttf-dejavu opendesktop-fonts ttf-bitstream-vera ttf-arphic-ukai ttf-arphic-uming ttf-hanazono --noconfirm --noprogressbar --quiet
pacman -S yajl --noconfirm --noprogressbar --quiet
cd
rm -rf ~/Downloads/*
pacman -S firefox filezilla cherrytree gimp libreoffice libreoffice-fresh-ru kdenlive audacity pidgin screenfetch mplayer smplayer smplayer-themes qt4 ufw guvcview transmission-qt simplescreenrecorder gparted f2fs-tools dosfstools ntfs-3g alsa-lib gnome-calculator file-roller p7zip unrar gvfs aspell-ru klavaro gedit --noconfirm --noprogressbar --quiet
exit
umount -R /mnt
reboot
