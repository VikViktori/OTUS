#!/bin/bash

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
