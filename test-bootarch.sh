# воспользовался материалом в личных целях 
USER='root' 
cd /data/local/arch 
if ! mountpoint -q dev; then	
mount -t proc /proc proc	
mount -o bind /dev dev 
mount -o bind /dev/pts dev/pts
mount -r -o bind /sys sys
mount -r -o bind /sdcard sdcard
mount -r -o bind /system/bin system/bin
mount -r -o bind /system/xbin system/xbin
mount -r -o bind /system/lib system/lib
fi
chroot . /bin/bash -c "source /etc/profile; export HOME=/home/${USER}; export TERM=xterm-256color; clear; su - ${USER}" 