# Файловые системы и LVM


Для начала необходимо установить пакет **xfsdump**, он необходим для снятия копии тома.

Подготовим временный том для / раздела

```bash
[root@lvm ~]# pvcreate /dev/sdb
 Physical volume "/dev/sdb" successfully created.
[root@lvm ~]# vgcreate vg_root /dev/sdb
 Volume group "vg_root" successfully created
[root@lvm ~]# lvcreate -n lv_root -l +100%FREE /dev/vg_root
 Logical volume "lv_root" created.
```

Создаем файловую систему на разделе, смонтируем его, чтобы перенести туда данные
rsync командой копируем все данные с / раздела в /mnt:

```bash
[root@lvm ~]# mkfs.ext4 /dev/vg_root/lv_root
[root@lvm ~]# mount /dev/vg_root/lv_root /mnt
[root@lvm ~]# rsync -avxHAX --progress / /mnt/
многобукв
sent 626,000,103 bytes  received 641,485 bytes  7,688,853.84 bytes/sec
total size is 636,957,273  speedup is 1.02
for i in /proc/ /sys/ /dev/ /run/ /boot/; \
>  do mount --bind $i /mnt/$i; done
mount: only root can use "--bind" option
mount: only root can use "--bind" option
mount: only root can use "--bind" option
mount: only root can use "--bind" option
mount: only root can use "--bind" option
[root@lvm ~]$ for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
mount: only root can use "--bind" option
mount: only root can use "--bind" option
mount: only root can use "--bind" option
mount: only root can use "--bind" option
mount: only root can use "--bind" option

```

Чтобы при старте перейти в новый корень, конфигурируем grub

Затем сконфигурируем grub для того, чтобы при старте перейти в новый /.
Сымитируем текущий root, сделаем в него chroot и обновим grub:


```bash
[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
```

Чтобы нужный рут грузился нужно поправить

```bash
[root@lvm /]# cd /boot ; for i in ls initramfs-*img; do dracut -v $i echo $i|sed "s/initramfs-//g; s/.img//g" --force; done 
root@lvm boot]# sudo vi /boot/grub2/grub.cfg 
change on rd.lvm.lv=vg_root/lv_root
```
Перезагружаемся успешно с новым root томом

Теперь нам нужно изменить размер старой VG и вернуть на него рут. Для этого удаляем старый LV размеров в 40G и создаем новый на 8G

```bash
[root@lvm ~]# lvremove /dev/VolGroup00/LogVol00
[root@lvm ~]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
```

Проделываем на нем те же операции, что и в первый раз:


```bash
[root@lvm ~]# mkfs.ext4 /dev/VolGroup00/LogVol00

[root@lvm ~]# mount /dev/VolGroup00/LogVol00 /mnt

[root@lvm ~]# rsync -avxHAX --progress / /mnt/

```



Так же как в первый раз cконфигурируем grub.
```bash
[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
```

Повторно обновляем 

```bash
[root@lvm /]# cd /boot ; for i in ls initramfs-*img; do dracut -v $i echo $i|sed "s/initramfs-//g; s/.img//g" --force; done 
```

Пока не перезагружаемся и не выходим из под chroot - мы можем заодно перенести /var.

На свободных дисках создаем зеркало

```bash
[root@lvm ~]# pvcreate /dev/sdc /dev/sdd 
[root@lvm ~]# vgcreate vg_var /dev/sdc /dev/sdd 
[root@lvm ~]# lvcreate -L 950M -m1 -n lv_var vg_var 
```

Создаем ФС и перемещаем туда /var, на всякий случай сохраняем содержимое старого var

```bash
[root@lvm ~]# mkfs.ext4 /dev/vg_var/lv_var
[root@lvm ~]# mount /dev/vg_var/lv_var /mnt
[root@lvm ~]# cp -aR /var/* /mnt/
[root@lvm ~]# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
[root@lvm ~]# umount /mnt
[root@lvm ~]# mount /dev/vg_var/lv_var /var
[root@lvm ~]# echo "`blkid | grep var: | awk '{print $2}'`  /var ext4 defaults 0 0" >> /etc/fstab

```

Перезагружаемся в новый root и удаляем временный Volume Group

```bash
[root@lvm ~]# lvremove /dev/vg_root/lv_root 
[root@lvm ~]# vgremove /dev/vg_root 
[root@lvm ~]# pvremove /dev/sdb 
```

Выделяем том под /home по тому же принципу что делали для /var

```bash
[root@lvm ~]# mkfs.ext4 /dev/ubuntu-vg/LogVol_Home
[root@lvm ~]# mount /dev/ubuntu-vg/LogVol_Home /mnt/
[root@lvm ~]# cp -aR /home/* /mnt/
[root@lvm ~]# rm -rf /home/*
[root@lvm ~]# umount /mnt
[root@lvm ~]# mount /dev/ubuntu-vg/LogVol_Home /home/
[root@lvm ~]# lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
[root@lvm ~]# mount /dev/VolGroup00/LogVol_Home /home/
```



Правим fstab для автоматического монтирования /home:

[root@lvm ~]# echo "`blkid | grep Home | awk '{print $2}'` \
 /home xfs defaults 0 0" >> /etc/fstab



Правим **fstab** для автоматического монтирования **/home** 

```bash
[root@lvm ~]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
```

 Генерируем файлы в **/home** и делаем снапшот

```bash
[root@lvm ~]# touch /home/file{1..20} 
[root@lvm ~]# lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
```

Удаляем часть файлов 

```bash
[root@lvm ~]# rm -f /home/file{11..20} 
```

Восстанавливаем из снапшота

```bash
[root@lvm ~]# umount /home 
[root@lvm ~]# lvconvert --merge /dev/VolGroup00/home_snap 
[root@lvm ~]# mount /home
```







