#!/bin/bash
# 2

nano /etc/locale.gen

# ru_RU.UTF-8 UTF-8 en_US.UTF-8 UTF-8.

locale-gen

echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

# Mkinitcpio
# Mkinitcpio генерирует initramfs. И так как мы использовали два модуля, которые не включены по-умолчанию encrypt и lvm2, нам надо их включить.


nano /etc/mkinitcpio.conf

# Дойдем до строки с хуками и добавим туда encrypt и lvm2:

# HOOKS=(base udev autodetect modconf block filesystems keyboard encrypt lvm2 fsck)


# пересобрать initramfs:

mkinitcpio -p linux

pacman -S grub dosfstools efibootmgr mtools

nano /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

grub-install /dev/nvme0n1


cryptsetup luksUUID /dev/nvme0n1p4


sudo EDITOR=nano visudo
# И в этом файле надо раскомментить строку:

# %wheel ALL=(ALL) ALL


useradd -m -s /bin/bash admin 
passwd admin

umount -R

exit

reboot

