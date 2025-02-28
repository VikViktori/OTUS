# # # install zfs repo
  sudo cd /etc/yum.repos.d/
  sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
  sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#  sudo yum update -y
#  sudo yum install -y zfs
sudo mkdir -p ~root/.ssh
sudo cp ~vagrant/.ssh/auth* ~root/.ssh
sudo yum install -y mdadm smartmontools hdparm gdisk

