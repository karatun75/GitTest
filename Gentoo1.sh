#!/bin/bash
# Gentoo1
# https://vk.com/@poruncov-chek-list-po-ustanovke-gemtoo-x86-64

ping -c17 8.8.8.8

# ls /dev/nvme*
# ls /dev/sd*

# lsblk

# blkid

# gdisk /dev/nvme0n1
# mklabel gpt 
# mkpart ESP fat32 1MiB 512MiB 
# set 1 boot on 
# mkpart primary
# Теперь можем настроить шифрование на втором диске:
# n
# t
# L 
# 8309

cryptsetup luksFormat /dev/nvme0n1p4

cryptsetup open /dev/nvme0n1p4 luks

# пароль  "luks"

echo 'ls /dev/mapper/*'

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

mount /dev/mapper/steel-root /mnt/gentoo

chmod 1777 /mnt/gentoo/tmp

mkdir -p /mnt/{home,boot/efi}
mount /dev/nvme0n1p1 /mnt/boot/efi
mount /dev/mapper/steel-home /mnt/home
swapon /dev/mapper/steel-swap

# Gentoo

cd /mnt/gentoo

links https://www.gentoo.org/downloads/mirrors/

tar xpvf «имя архива».tar.bz2 --xattrs-include='*.*' --numeric-owner


# Теперь настроим параметры компиляции

nano -w /mnt/gentoo/etc/portage/make.conf

# Строку

# COMMON_FLAGS="-O2 -pipe"

# Приведем ее к виду 
COMMON_FLAGS="-march=native -O2 -pipe"
# Но данный параметр позволит работать только на данной машине!!!

# Далее укажем количество ядер/потоков компиляции:

MAKEOPTS="-j20"

# Установка базовой системы Gentoo

# Копирование информации о DNS:

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# Подключение необходимых файловых систем и настройка chroot

mount --types proc /proc /mnt/gentoo/proc

mount --rbind /sys /mnt/gentoo/sys

mount --make-rslave /mnt/gentoo/sys

mount --rbind /dev /mnt/gentoo/dev

mount --make-rslave /mnt/gentoo/dev

# CHROOT

chroot /mnt/gentoo /bin/bash

source /etc/profile

export PS1="(chroot) ${PS1}"

# Выбор подходящего профиля:

emerge --sync

eselect profile list

# Чек лист по установке Gentoo x86-64, изображение №7
# Выбираем подходящий профиль:

# eselect profile set N

# Например для I3wm

eselect profile set 20

# Обновление @world

emerge --ask --verbose --update --deep --newuse @world

____________________________________________________________________________________________

Настройка USE переменной

nano -w /etc/portage/make.conf

Пример:

COMMON_FLAGS="-march=native -O2 -pipe"

CFLAGS="${COMMON_FLAGS}"

CXXFLAGS="${COMMON_FLAGS}"

FCFLAGS="${COMMON_FLAGS}"

FFLAGS="${COMMON_FLAGS}"

# NOTE: This stage was built with the bindist Use flag enabled

PORTDIR="/var/db/repos/gentoo"

DISTDIR="/var/cache/distfiles"

PKGDIR="/var/cache/binpkgs"

# This sets the language of build output to English.

# Please keep this setting intact when reporting bugs.

LC_MESSAGES=C

MAKEOPTS=" -j3 "

USE="X bluetooth -gpm alsa unicode ABI_X86=64 dbus amd64 abi_x86_32 qt4 qt5 -gnome -kde -dvd -cdr pulseaudio i3wm"

VIDEO_CARDS="intel" # для драйвера video карты

Чек лист по установке Gentoo x86-64, изображение №8
ACCEPT_LICENSE="*" # принимаем все условия лицензионного согдашения

LANGUAS="ru"

L10N="ru»

____________________________________________________________________________________________

Настроим время

ls /usr/share/zoneinfo

echo "Europe/Moscow" > /etc/timezone

перенастроим пакет sys-libs/timezone-data

emerge --config sys-libs/timezone-data

____________________________________________________________________________________________

Настройка локалей

nano -w /etc/locale.gen

en_US.UTF-8 UTF-8

ru_RU.UTF-8 UTF-8

пример настройки

Чек лист по установке Gentoo x86-64, изображение №9
locale-gen

Теперь выберем локаль по умолчанию

eselect locale list

Чек лист по установке Gentoo x86-64, изображение №10
в моем случае set 5

eselect locale set 5

далее добавим поддержку кириллицы в консоли:

nano /etc/conf.d/consolefont

и добавим cyr-san16

вот пример готового файла

Чек лист по установке Gentoo x86-64, изображение №11
далее включим службу consolefont

добавим

rc-update add consolefont boot

rc-service consolefont start

перезапустим окружение

env-update && source /etc/profile && export PS1="(chroot) ${PS1}»

____________________________________________________________________________________________

Настройка ядра Linux

emerge --ask sys-kernel/gentoo-sources << добавил lspci в систему

Есть 2 пути ручной и скрипт для сборки с использованием genkernel

ручная сборка частично описана тут » тык

____________________________________________________________________________________________

genkernel

emerge --ask sys-kernel/genkernel

далее нам необходимо отредактировать fstab

nano /etc/fstab

В процессе настройки Gentoo /etc/fstab еще будет изменён. На данный момент мы правим лишь /boot, так как genkernel использует эту настройку.

если отдельный boot (mbr-legacy)

/dev/sda1	/boot	ext2	defaults	0 2
UEFI

/dev/sda1	/boot	vfat rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro    0 2  
Теперь запустим сборку ядра

Данный процесс может занять продолжительное время

genkernel all

Установка файлов прошивки для работы устройств

emerge --ask sys-kernel/linux-firmware

# __________________________________________________________________________________________

# Редактирование файла fstab

nano /etc/fstab

# пример файла

# Чек лист по установке Gentoo x86-64, изображение №12
# UUID можно узнать с помощью blkid

# для большего удобства можно сделать так

blkid /dev/sda1 >> /etc/fstab

blkid /dev/sda2 >> /etc/fstab

blkid /dev/sda3 >> /etc/fstab

blkid /dev/sda4 >> /etc/fstab

Для UEFI укажем

UUID='увказать свои значения без кавычек' /boot vfat rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro 0 2

все остальное так же как

UUID= none swap sw 0 0

UUID= / ext4 rw,relatime 0 1

UUID= /home ext4 rw,relatime 0 2

# __________________________________________________________________________________________

# Теперь включим локальное время

nano /etc/conf.d/hwclock

# и в строке clock указать 'local'

# clock="local»

# __________________________________________________________________________________________

# Опционально: Удаленный доступ

rc-update add sshd default

# установка утилиты для корректной работы FS

emerge --ask sys-fs/e2fsprogs

# Установка DHCP клиента

emerge --ask net-misc/dhcpcd

# Опционально: Установка PPPoE клиента

emerge --ask net-dialup/ppp

# Опционально: Установка утилит для беспроводной сети

emerge --ask net-wireless/iw net-wireless/wpa_supplicant

#__________________________________________________________________________________________

# Установка загрузчика

# __________________________________________________________________________________________

# Если у вас UEFI тогда перед сборкой grub добавьте

# nano /etc/portage/make.conf

# GRUB_PLATFORMS=''efi-64'' (кавычки двойные)

# либо так можно так

echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf

emerge --ask --update --newuse --verbose sys-boot/grub:2

# __________________________________________________________________________________________

# Если Legacy(mbr )

# emerge --ask --verbose sys-boot/grub:2

# Установим загрузчик на hdd

# Когда используется BIOS(Legacy ):
# grub-install /dev/sda

#Когда используется UEFI:

grub-install --target=x86_64-efi --efi-directory=/boot --removable

# Обновим конфигурационный файл grub

# Если дуал boot (установка рядом с Windows например)

# установите:

emerge --ask sys-boot/os-prober

grub-mkconfig -o /boot/grub/grub.cfg

# подробно тут » тык

# __________________________________________________________________________________________

# Установим пароль root

passwd

Добавим пользователя

useradd -m -G users,wheel,audio,video -s /bin/bash #желаемое имя латинскими буквами

# установим пароль для пользователя

passwd admin

# __________________________________________________________________________________________

# Выходим из CHROOT

exit

cd

umount -l /mnt/gentoo/dev{/shm,/pts,}

umount -R /mnt/gentoo

reboot

________________________________________________________________________________









