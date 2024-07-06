#!/bin/bash
#LOCAL_HOST_IP="10.79.1.197"
KC_HOME="/opt/keycloak/"
KC_VERSION="keycloak-20.0.3"
VERSION="20.0.3"
PSQL_JAR="postgresql-42.5.4.jar"

echo "Update Linux, dnf, & Instal Java 11"
sudo yum update -y
#sudo yum install wget
sudo dnf update
sudo dnf -y install wget

#sudo amazon-linux-extras install epel -y
#sudo amazon-linux-extras install java-openjdk11 -y
sudo dnf install java-11-openjdk java-11-openjdk-devel -y
#sudo yum install java-11-openjdk-devel -y
java --version
javac --version

echo "Create keycloak directory"
sudo mkdir $KC_HOME                                     
sudo chown rocky:rocky $KC_HOME
ls -las $KC_HOME

echo "Create models directory & Attempt model dir ebs volume mount on Keycloak instances"
sudo mkdir /var/opt/keycloak/
sudo mkfs -t xfs /dev/xvda1
sudo mount /dev/xvda1 /var/opt/keycloak
sudo chown rocky:rocky /var/opt/keycloak/

echo "Check model-dir mount"
ls -las /var/opt/keycloak/
sudo lsblk -f
sudo file -s /dev/xvda1
sudo blkid

echo "Install Key Cloak"
sudo wget https://github.com/keycloak/keycloak/releases/download/$VERSION/$KC_VERSION.tar.gz
sudo tar -C /opt/keycloak -xzf $KC_VERSION.tar.gz
sudo chown rocky:rocky -R $KC_HOME  

echo "Update Linux and prepare for postgres #requires Centos 7 AMI"
sudo yum update -y
sudo yum install -y python3

echo "Install Pip (Pip is not available in CentOS 7 core repositories)"
#sudo yum install python3-pip -y --user
pip3 install requests
sudo yum install epel-release -y

echo "Create Postgres modules directory & chown directories"
sudo mkdir -p /opt/keycloak/$KC_VERSION/modules/system/layers/keycloak/com
sudo chown rocky:rocky -R /opt/keycloak/$KC_VERSION/modules/
sudo ls -las /opt/keycloak/$KC_VERSION/modules/system/layers/keycloak/com
sudo ls -las /opt/keycloak/$KC_VERSION/modules/

echo "Install Postgres JDBC driver"
sudo wget -c https://jdbc.postgresql.org/download/$PSQL_JAR -P /opt/keycloak/$KC_VERSION/modules/system/layers/keycloak/com
ls -las /opt/keycloak/$KC_VERSION/modules/system/layers/keycloak/com
file /opt/keycloak/$KC_VERSION/modules/system/layers/keycloak/com/$PSQL_JAR
touch /opt/keycloak/$KC_VERSION/modules/system/layers/keycloak/com/module.xml
sudo chown rocky:rocky -R /opt/keycloak/$KC_VERSION/modules/system/layers/keycloak/com
# Fill out module.xml manually

echo "Install postgres 14 on amazon linux2 https://devopscube.com/install-configure-postgresql-amazon-linux/"
#sudo amazon-linux-extras enable postgresql14
sudo yum install postgresql-server -y
postgresql-setup --initdb --unit postgresql
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo systemctl status postgresql

echo "Add entries in /var/lib/pgsql/data/pg_hba.conf to allow md5 auth for all & postgres User"
sudo su
echo 'host      all           all             0.0.0.0/0               md5' >> /var/lib/pgsql/data/pg_hba.conf
echo 'host      all           postgres        127.0.0.1/32            md5' >> /var/lib/pgsql/data/pg_hba.conf

echo "Add Listener entry in /var/lib/pgsql/data/postgresql.conf "
sudo su
echo "listen_addresses = '*'" >> /var/lib/pgsql/data/postgresql.conf

echo "Update /etc/fstab for mount"
sudo su
echo  "/dev/xvda1       /var/opt/keycloak        xfs     defaults,noatime        0       0  " >> /etc/fstab
sudo mount -a

#echo "Install CloudWatch Agent"
#sudo yum install amazon-cloudwatch-agent -y

echo "Show boto and python versions"
pip3 list | grep boto
python -V
python3 --version

echo "Install Dev Tools"
sudo yum groupinstall "Development tools" -y                                                                                                           #for gcc compiler

#echo "For troubleshooting flexlm, install telnet"
#sudo yum -y install telnet

echo "configure_postgres14.sh"

echo "Configure $KC_HOME $KC_VERSION/conf/keycloak.conf > configure_kc_prod.sh"
cp /opt/keycloak/$KC_VERSION/conf/keycloak.conf /opt/keycloak/$KC_VERSION/conf/keycloak.conf.orig
sed -i "s;#db=postgres;db=postgres;g" /opt/keycloak/$KC_VERSION/conf/keycloak.conf
sed -i "s;#db-username=keycloak;db-username=keycloak;g" /opt/keycloak/$KC_VERSION/conf/keycloak.conf
sed -i "s;#db-password=password;db-password=keycloak;g" /opt/keycloak/$KC_VERSION/conf/keycloak.conf
sed -i "s;#hostname=myhostname;hostname=keycloak.local:8443;g" /opt/keycloak/$KC_VERSION/conf/keycloak.conf
sed -i "s;#proxy=reencrypt;proxy=edge;g" /opt/keycloak/$KC_VERSION/conf/keycloak.conf 
sudo chown rocky:rocky /opt/keycloak/$KC_VERSION/conf/keycloak.conf 
ls -las /opt/keycloak/$KC_VERSION/conf/keycloak.conf

sudo sed -i "s;127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4;127.0.0.1   localhost keycloak.local neitzche.qcloud.systems localdomain4;g" /etc/hosts
#/etc/hosts
#keycloak.local
#confucious.qcloud.systems

echo "Configure hosts file"
echo "Javascript must be enabled to run this app https://stackoverflow.com/questions/8205369/installing-npm-on-aws-ec2"
#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
#. ~/.nvm/nvm.sh
#npm install -g npm
#nvm install 16
#node -e "console.log('Running Node.js ' + process.version)"
#curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
#sudo yum install nodejs -y
#node --version
#npm --version
#sudo dnf remove nodejs npm -y
#sudo dnf install nodejs -y

sudo dnf install -y nodejs