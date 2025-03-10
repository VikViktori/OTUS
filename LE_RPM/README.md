## RPM

Описание
1) Создать свой RPM пакет (можно взять свое приложение, либо собрать, например,
Apache с определенными опциями).
2) Создать свой репозиторий и разместить там ранее собранный RPM.
Реализовать это все либо в Vagrant, либо развернуть у себя через Nginx и дать ссылку на репозиторий.

```bash
vagrant up
vagrant ssh
[vagrant@RPM ~]$ sudo cd /etc/yum.repos.d/
[vagrant@RPM ~]$ sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
[vagrant@RPM ~]$ sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
[vagrant@RPM ~]$ sudo yum install -y \
  redhat-lsb-core \
  wget \
  rpmdevtools \
  rpm-build \
  createrepo \
  yum-utils \
  gcc
#загружаем nginx,openssl => unzip# tar -xvf latest.tar.gz - скачивается зип
[vagrant@RPM ~]$ sudo yum install -y wget rpmdevtools rpm-build createrepo \
 yum-utils cmake gcc git nano

[vagrant@RPM ~]$ sudo wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm rpm -i nginx-1.*
[vagrant@RPM ~]$ sudo wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
[vagrant@RPM ~]$ sudo yum install unzip
[vagrant@RPM ~]$ sudo unzip OpenSSL_1_1_1-stable.zip

[vagrant@RPM ~]$ sudo yum-builddep rpmbuild/SPECS/nginx.spec
[vagrant@RPM ~]$ sudo vim rpmbuild SPECS/nginx.spec
# добавляем опцию --with-openssl=/home/vagrant/openssl-OpenSSL_1_1_1-stable в ./configure и удаляем --with-debug
[vagrant@RPM ~]$ rpmbuild -bb rpmbuild/SPECS/nginx.spec
Проверяем
ll rpmbuild/RPMS/x86_64/
[vagrant@RPM ~]$ sudo yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
[vagrant@RPM ~]$ sudo systemctl start nginx
[vagrant@RPM ~]$ sudo systemctl status nginx
```

Создаем свою реп

```bash
#создаем директорию для пакетов и помещаем туда наш пакет и еще один из интернета
[vagrant@RPM ~]$ sudo mkdir /usr/share/nginx/html/repo
[vagrant@RPM ~]$ sudo cp rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
[vagrant@RPM ~]$ sudo wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm \
  -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
[vagrant@RPM ~]$ sudo createrepo /usr/share/nginx/html/repo/
# 1- добавляем директиву autoindex on; в секцию "location /"
#2- проверяем синтаксис конфигурации
# перезапуск
[vagrant@RPM ~]$ sudo vim /etc/nginx/conf.d/default.conf
[vagrant@RPM ~]$ sudo nginx -t
[vagrant@RPM ~]$ sudo nginx -s reload
[vagrant@RPM ~]$ curl -a http://localhost/repo/

Добавим новую репу в систему
[vagrant@RPM ~]$ sudo -i
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
exit
ЧЕКаем
yum repolist enabled | grep otus


