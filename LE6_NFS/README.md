# NFS

ДЗ:

- `vagrant up` должен поднимать 2 настроенных виртуальных машины
(сервер NFS и клиента) без дополнительных ручных действий;
- на сервере NFS должна быть подготовлена и экспортирована
директория;
- в экспортированной директории должна быть поддиректория
с именем __upload__ с правами на запись в неё;
- экспортированная директория должна автоматически монтироваться
на клиенте при старте виртуальной машины (systemd, autofs или fstab -
любым способом);
- монтирование и работа NFS на клиенте должна быть организована
с использованием NFSv3 по протоколу UDP;
- firewall должен быть включен и настроен как на клиенте,
так и на сервере.

Создаём 2 виртуальные машины с сетевыми интерфейсами, которые позволяют связь между ними. 
Далее будем называть ВМ с NFS сервером (IP 192.168.56.101), а ВМ с клиентом (IP 192.168.56.102).
```bash
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

#Установка необходимого ПО
sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
sudo yum install nfs-utils -y
sudo systemctl enable firewalld --now
sudo systemctl status firewalld
#Настраиваем фаервол
sudo firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent
sudo firewall-cmd --reload
sudo ss -tnplu
sudo systemctl enable nfs --now
#Создаем директории и назначаем владельца и права
sudo mkdir -p /srv/share/upload
sudo chown -R nfsnobody:nfsnobody /srv/share
sudo chmod 0777 /srv/share/upload
sudo cat << EOF > /etc/exports
/srv/share 192.168.56.101/32(rw,sync,root_squash)
EOF
#Задаем шару со стороны сервера
sudo echo "mnt/nfs    192.168.56.102(rw,nohide,sync,root_squash)" >> /etc/exports
#Добавляем в автозагрузку и запускаем необходимые сервесы
systemctl enable rpcbind nfs-server firewalld
systemctl start rpcbind nfs-server firewalld
```

На клиенте почти также 
```bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

#Установка необходимого ПО
sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
sudo yum install nfs-utils -y
#Создаем директории и назначаем права
sudo mkdir -p /srv/share/upload
sudo chown -R nfsnobody:nfsnobody /srv/share
#Правим fstab
echo "192.168.56.101:/mnt/nfs /mnt/share nfs noauto,x-systemd.automount,proto=udp,vers=3 0 0" >> /etc/fstab
#Хак для noauto,x-systemd.automount
systemctl restart remote-fs.target
#Добавляем в автозагрузку и запускаем необходимые сервесы
systemctl enable rpcbind firewalld
systemctl start rpcbind firewalld
#Настраиваем фаервол
sudo firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent
sudo firewall-cmd --reload
#Перезагружаем
shutdown -r now
```