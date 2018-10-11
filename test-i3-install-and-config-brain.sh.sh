#!/bin/bash
# Воспользовмлся материалом в личных целях
# Ссылка на источник https://pastebin.com/X6PUbXQm 
# Автор предлагает воспользоваться скриптом
# надо до работать для своего железа
echo "Введите имя пользователя: "
# Считываем имя пользователя
read user
# Проверяем, что скрипт запущен из под рута
if [[ "$(whoami)" != "root" ]]; then
	echo "Скрипт запущен не от суперпользователя. Запустите от root!";
	exit;
fi
# Быстрый установщик пакетов из AUR
pacman -S yaourt --noconfirm
# Регулятор громкости alsa
pacman -S alsa-utils --noconfirm
# Шрифты
pacman -S ttf-droid ttf-dejavu --noconfirm
# Терминал
pacman -S rxvt-unicode --noconfirm
# Запускатор приложений
pacman -S dmenu --noconfirm
# Просмотрщик картинок / обои на рабочий стол
pacman -S feh --noconfirm
# Текстовый редактор
pacman -S vim --noconfirm
# Менеджер буфера обмена
pacman -S parcellite--noconfirm
# GTK-движок и конфигуратор тем
pacman -S lxappearance gtk-engines--noconfirm
# Браузер
pacman -S chromium --noconfirm
# Flash-плагин для браузера
pacman -S flashplugin --noconfirm
# Просмотрщик изображений
pacman -S sxiv --noconfirm
# Видео плеер
pacman -S mplayer-vaapi --noconfirm
# Музыкальный сервер
pacman -S mpd --noconfirm
# Клиент для музыкального сервера
pacman -S ncmpcpp --noconfirm
# RSS-читалка
pacman -S newsbeuter --noconfirm
# Скриншоттер
pacman -S scrot --noconfirm
# Торрент-качалка
pacman -S rtorrent --noconfirm
# PolicyKit (для выключения, ребута и т.д. через systemctl)
pacman -S polkit --noconfirm
# Месенджер
pacman -S finch --noconfirm
# i3
yaourt -S i3-git i3status-git --noconfirm
# Простая утилита для замены конца строки из dos в unix
pacman -S dos2unix --noconfirm
# Включение крона
systemctl enable cronie.service
# Создание папок под конфиги и файлы
su -c 'mkdir ~/.i3' $user
# 
su -c 'mkdir ~/.ncmpcpp' $user
# 
su -c 'mkdir -p ~/.mpd/playlists' $user
# Создаём папку под музыку
su -c 'mkdir ~/music' $user
# Создаём папку под обои на рабочий стол
su -c 'mkdir ~/.wallpaper' $user
# Создаём папку под скрины
su -c 'mkdir ~/screens' $user
su -c 'touch ~/.mpd/database' $user
# Создаём папку под содержимое торрентов
su -c 'mkdir -p ~/torrents/download' $user
# Создаём папку под торрент-файлы
su -c 'mkdir ~/torrents/to_download' $user
# Создаём папку для сессий
su -c 'mkdir ~/torrents/.session' $user
# Создаём папку для RSS
su -c 'mkdir ~/.newsbeuter' $user
# Удаляем локальный bashrc
su -c 'rm ~/.bashrc' $user
# Скачиваем конфиги i3
su -c 'curl http://pastebin.com/raw.php?i=sS7XcB2W > ~/.i3/config' $user
# 
su -c 'curl http://pastebin.com/raw.php?i=p26DHWEt > ~/.i3/i3status.conf' $user
# 
su -c 'curl http://pastebin.com/raw.php?i=1zvvJPW7 > ~/.i3/status.sh' $user
# 
su -c 'curl http://pastebin.com/raw.php?i=ai7v0xF6 > ~/.xinitrc' $user
# 
su -c 'curl http://pastebin.com/raw.php?i=mh7aVJUK > ~/.Xresources' $user
# Скачиваем конфиг Rss-читалки
su -c 'curl http://pastebin.com/raw.php?i=nXFbd0Up > ~/.newsbeuter/config' $user
# Скачиваем конфиг mpd
su -c 'curl http://pastebin.com/raw.php?i=0ABF4cRe > ~/.mpdconf' $user
# Скачиваем конфиг ncmpcpp
su -c 'curl http://pastebin.com/raw.php?i=GqSBDskJ > ~/.ncmpcpp/config' $user
# Скачиваем конфиг rtorrent
su -c 'curl http://pastebin.com/raw.php?i=rxcTDRdE > ~/.rtorrent.rc' $user
# Скачаваем конфиг bash для пользователя (делаем автологин)
su -c 'curl http://pastebin.com/raw.php?i=CQ60L9bW > ~/.bash_profile' $user
# Скачивам bashrc
curl 'http://pastebin.com/raw.php?i=jedvHFJW' > /etc/bash.bashrc
# Конвертируем из DOS в UNIX все файлы, которые скачали
su -c 'dos2unix  ~/.i3/* ~/.xinitrc ~/.Xresources ~/.mpdconf ~/.ncmpcpp/config ~/.rtorrent.rc ~/.newsbeuter/config ~/.bash_profile' $user
dos2unix /etc/bash.bashrc
# Устанавливам права на скрипты
su -c 'chmod +x ~/.i3/status.sh' $user
# Настраиваем крон
echo "*/15 * * * * DISPLAY=:0.0 feh --bg-scale \"\$(find ~/.wallpaper/|shuf -n1)\"" > /tmp/crontab.file
crontab -u $user /tmp/crontab.file
rm /tmp/crontab.file
# Заканчиваем выполнение
echo -e "Готово! Можно перезагружать компьютер.\n© Brain, 2012"
