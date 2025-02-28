
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