#!/bin/bash
# 2
if
nano /etc/locale.gen

# ru_RU.UTF-8 UTF-8 en_US.UTF-8 UTF-8.

echo "locale-gen"

echo "LANG="ru_RU.UTF-8" > /etc/locale.conf"

echo "KEYMAP=ru >> /etc/vconsole.conf"
echo "FONT=cyr-sun16 >> /etc/vconsole.conf"

# Mkinitcpio
# Mkinitcpio генерирует initramfs. И так как мы использовали два модуля, которые не включены по-умолчанию encrypt и lvm2, нам надо их включить.


nano /etc/mkinitcpio.conf

# Дойдем до строки с хуками и добавим туда encrypt и lvm2:

echo "# HOOKS=(base udev autodetect modconf block filesystems keyboard > encrypt lvm2 < fsck)"


echo "# пересобрать initramfs:"

echo "mkinitcpio -p linux"

echo "pacman -S grub dosfstools efibootmgr mtools"

nano /etc/default/grub

echo "grub-mkconfig -o /boot/grub/grub.cfg"

echo "grub-install /dev/nvme0n1"


echo "cryptsetup luksUUID /dev/nvme0n1p4"
echo "pacman -Sy i3 cinnamon ranger polybar rofi flameshot timeshift chromium"  

echo "sudo EDITOR=vim visudo"
echo "# И в этом файле надо раскомментить строку:"
echo "# %wheel ALL=(ALL) ALL"


echo "useradd -m -s /bin/bash admin"
echo "passwd"
echo "passwd admin"

echo "#umount -R /mnt"

echo "#exit"

echo "#reboot"

fi

