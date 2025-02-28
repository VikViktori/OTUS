
Чтобы установить саму zfs

```bash
[vagrant@localhost ~]# cat /etc/redhat-release 
CentOS Linux release 8.1.1911  (Core)
[vagrant@localhost ~]sudo cd /etc/yum.repos.d/
[vagrant@localhost ~]sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
[vagrant@localhost ~]sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
[vagrant@localhost ~]# yum install http://download.zfsonlinux.org/epel/zfs-release.el8_1.noarch.rpm
[vagrant@localhost ~]# gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
```

DKMS отключаем 
zfs-kmod включаем 

```bash
[vagrant@localhost ~]# vi /etc/yum.repos.d/zfs.repo
 [zfs]
 name=ZFS on Linux for EL 8 - dkms
 baseurl=http://download.zfsonlinux.org/epel/7/$basearch/
 enabled=0
 metadata_expire=7d
 gpgcheck=1
 gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

 [zfs-kmod]
 name=ZFS on Linux for EL 8 - kmod
 baseurl=http://download.zfsonlinux.org/epel/7/kmod/$basearch/
 enabled=1
 metadata_expire=7d
 gpgcheck=1
 gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
```

```bash
[vagrant@localhost ~]# yum install zfs
```

Загружаем модуль zfs и создаем pool - 4 штуки
```bash
[vagrant@localhost ~]# /sbin/modprobe zfs
[vagrant@localhost ~]# zpool create zfspool sdb
```
```bash
[vagrant@localhost ~]$  lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   10G  0 disk 
`-sda1   8:1    0   10G  0 part /
sdb      8:16   0   10G  0 disk 
sdc      8:32   0    2G  0 disk 
sdd      8:48   0    1G  0 disk 
sde      8:64   0    1G  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0  512M  0 disk 
[vagrant@localhost ~]$ ^C

```
Возможны следующие варианты сжатия
 

```bash
'compression' must be one of 'on | off | lzjb | gzip | gzip-[1-9] | zle | lz4'
```

1)
ФС

```bash
[vagrant@localhost ~]# zpool create otus1 mirror /dev/sdd /dev/sde
[vagrant@localhost ~]# zpool create otus2 mirror /dev/sdf /dev/sdg
[vagrant@localhost ~]# zpool create otus3 mirror /dev/sdh /dev/sdi
[vagrant@localhost ~]$ zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   960M   106K   960M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
[vagrant@localhost ~]$ 

```
Сжатие
```bash
[vagrant@localhost ~]# zfs set compression=lzjb otus1
[vagrant@localhost ~]# zfs set compression=gzip otus2
[vagrant@localhost ~]# zfs set compression=zle otus3
[vagrant@localhost ~]$ zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1    96K   832M       24K  /otus1
otus2    96K   352M       24K  /otus2
otus3  82.5K   352M       24K  /otus3
[vagrant@localhost ~]$ 
[vagrant@localhost ~]$ zfs get all  | grep compression
otus1  compression           lzjb                   local
otus2  compression           zle                    local
otus3  compression           off                    default
[vagrant@localhost ~]$ 


```

2)
Импортируем 

```bash
[vagrant@localhost ~]$ for i in {1..3}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
[vagrant@localhost ~]$ ls -l /otus*
/otus1:
total 22097
-rw-r--r--. 1 root root 41123477 Feb  2 08:31 pg2600.converter.log

/otus2:
total 40189
-rw-r--r--. 1 root root 41123477 Feb  2 08:31 pg2600.converter.log

/otus3:
total 40219
-rw-r--r--. 1 root root 41123477 Feb  2 08:31 pg2600.converter.log
[vagrant@localhost ~]$ 
[vagrant@localhost ~]$ zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  21.7M   810M     21.6M  /otus1
otus2  39.4M   313M     39.3M  /otus2
otus3  39.4M   313M     39.3M  /otus3
[vagrant@localhost ~]$ 


```

Пул - в зеркало.
Определение настроек пула
Скачиваем архив в домашний каталог:


```bash
[vagrant@localhost ~]#  wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download' 
```

Вывод

```bash
[vagrant@localhost ~]$ sudo tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
[vagrant@localhost ~]$ 
[vagrant@localhost ~]$ sudo zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        otus                                 ONLINE
          mirror-0                           ONLINE
            /home/vagrant/zpoolexport/filea  ONLINE
            /home/vagrant/zpoolexport/fileb  ONLINE
[vagrant@localhost ~]$ 
[vagrant@localhost ~]$ sudo zpool import -d zpoolexport/ otus
[vagrant@localhost ~]$ zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

        NAME                                 STATE     READ WRITE CKSUM
        otus                                 ONLINE       0     0     0
          mirror-0                           ONLINE       0     0     0
            /home/vagrant/zpoolexport/filea  ONLINE       0     0     0
            /home/vagrant/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: otus1
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

errors: No known data errors
```

3)Переносим snapshot, откатываем его предварительно скачав отсюда
wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download id=1wgxjih8YZ-cqLqaZVa0lA3h
3Y029c3oI&export=download

```bash
[vagrant@localhost ~]# zfs receive otus/test@today < otus_task2.file
```
Восстановим файловую систему из снапшота:
zfs receive otus/test@today < otus_task2.file
Далее, ищем в каталоге /otus/test файл с именем “secret_message”:
```bash
[root@zfs ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message

Смотрим содержимое найденного файла:
[root@zfs ~]# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/




```

