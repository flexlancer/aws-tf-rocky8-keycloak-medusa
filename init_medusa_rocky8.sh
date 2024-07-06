#!/bin/bash

echo "Update Linux, dnf, & Instal Java 11"
sudo yum update -y
sudo dnf -y install wget
dnf update -y
dnf install git -y

echo "Install Postgres 13"
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install postgresql13-server -y
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
sudo dnf install postgresql13-contrib -y 
echo "Enable Postgres 13"
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13 #Set postgres to start on startup

echo "Add entries in /var/lib/pgsql/data/pg_hba.conf to allow md5 auth for all & postgres User"
echo "Add Listener entry in /var/lib/pgsql/data/postgresql.conf "
sudo su
echo 'host      all           all             0.0.0.0/0               md5' >> /var/lib/pgsql/data/pg_hba.conf
echo 'host      all           postgres        127.0.0.1/32            md5' >> /var/lib/pgsql/data/pg_hba.conf
echo "listen_addresses = '*'" >> /var/lib/pgsql/data/postgresql.conf
exit

echo "Create postgres components"
sudo -u postgres psql << EOF
create database medusa;
create user medusa with encrypted password 'medusa';
grant all privileges on database medusa to medusa;
ALTER DATABASE medusa OWNER TO medusa;
EOF
sudo systemctl restart postgresql
sudo systemctl status postgresql

#echo "Install Docker stuff"
#sudo dnf install yum-utils -y
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
#sudo systemctl enable docker
#sudo systemctl start docker

cat /etc/passwd

echo "Install python3, python3-pip, pip3 install requests on alma8" 
sudo yum install -y python3
sudo yum install python3-pip -y
pip3 install requests
#sudo yum install epel-release -y
python3 --version
