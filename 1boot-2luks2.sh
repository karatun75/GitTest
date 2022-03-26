Грузимся из под live-usb, устанавливаем ru язык и время.

loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true
Подготовка к установке
Создаем таблицу на диске MBR(DOS) и 2 первичных раздела.

LUKS под root, swap, home
boot 1024M, выставляем флаг boot
cfdisk
Шифруем, открываем раздел. Создаем контейнер.

# подтверждаем YES
cryptsetup -y luksFormat --type luks2 /dev/sda2
cryptsetup open /dev/sda2 cryptlvm

pvcreate /dev/mapper/cryptlvm
vgcreate lvarch /dev/mapper/cryptlvm

ls -l /dev/mapper/cryptlvm
Создаём разделы lvm.

lvcreate -L 8G -n swap lvarch
lvcreate -L 100G -n root lvarch
lvcreate -l 100%FREE -n home lvarch
Форматируем и включаем swap.

mkfs.ext2 -L boot /dev/sda1
mkfs.ext4 -L root /dev/lvarch/root
mkfs.ext4 -L home /dev/lvarch/home
mkswap -L swap /dev/lvarch/swap
swapon /dev/lvarch/swap
Монтируем и создаем директории.

mount /dev/lvarch/root /mnt
mkdir /mnt/{home,boot}
mount /dev/lvarch/home /mnt/home
mount /dev/sda1 /mnt/boot
Установка и настройка
Установка базовой системы и необходимых пакетов.

pacstrap /mnt base base-devel linux linux-headers linux-firmware lvm2 nano networkmanager bash-completion reflector htop openssh curl wget git rsync unzip unrar p7zip gnu-netcat pv
Генерируем и правим, если нужно fstab, выполняем chroot.

genfstab -pU /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

arch-chroot /mnt
Включаем multilib и сортируем зеркала.

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

reflector -c "Russia" -c "Belarus" -c "Ukraine" -c "Poland" -f 20 -l 20 -p https -p http -n 20 --save /etc/pacman.d/mirrorlist --sort rate
Пароль root.

passwd
Создаем пользователя st в нужных группах, назначаем пароль и включаем sudo.

useradd -m -g users -G "adm,audio,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/bash -c "Alex Creio" admin

passwd admin

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
Назначаем hostname: имя машины и часовой пояс, время.

echo "arch" > /etc/hostname
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
timedatectl set-ntp true
Генерируем локали и включаем русский язык системы.

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
Добавляем поддержку ru в консоле.

echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf
Добавляем хуки (порядок важен) и создаем загрузочный образ.

### добавить keyboard keymap encrypt lvm2
# HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck)
nano /etc/mkinitcpio.conf

mkinitcpio -p linux
Устанавливаем Grub.

pacman -S --noconfirm --needed grub
grub-install /dev/sda
Настраиваем и конфигурируем grub.

## узнаём UUID
blkid /dev/sda2
# /dev/sda1: UUID="c0868972-f314-48e1-9be5-3584826dbd64" TYPE="crypto_LUKS" PARTUUID="bbb93e39-01"

nano /etc/default/grub

## Прописываем команду для старта и включаем.
GRUB_CMDLINE_LINUX="cryptdevice=UUID=c0868972-f314-48e1-9be5-3584826dbd64:cryptlvm root=/dev/lvarch/root"
GRUB_ENABLE_CRYPTODISK=y

## конфигурируем
grub-mkconfig -o /boot/grub/grub.cfg
Включаем необходимые сервисы.

systemctl enable NetworkManager
systemctl enable sshd
Выходим из chroot, отмонтируем разделы и закроем контейнер.

exit
umount -Rf /mnt
vgchange -a n lvarch
cryptsetup close cryptlvm
Резервное копирование luksHeader
Просмотр информации.

cryptsetup luksDump /dev/sda2
Обязательно создайте backup заголовка.

cryptsetup luksHeaderBackup /dev/sda2 --header-backup-file luksheader.bac
Шифруем.

openssl enc -aes-256-cbc -salt -in luksheader.bac -out luksheader.bac.enc
rm luksheader.bac
Расшифровываем.

openssl enc -d -aes-256-cbc -in luksheader.bac.enc -out luksheader.bac
Восстанавливаем, подтверждаем: YES.

cryptsetup luksHeaderRestore --header-backup-file luksheader.bac /dev/sda2

Сохраняем в надёжное место luksheader.bac.enc, например на usb. Стеганографируем и в публичный доступ, о этом я рассказывал в данном видео.
https://youtu.be/sGIrre2OVt4