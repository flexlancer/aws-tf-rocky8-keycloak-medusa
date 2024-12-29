#!/bin/bash
KC_HOME="/opt/keycloak/"
KC_VERSION="keycloak-20.0.3"
VERSION="20.0.3"
PSQL_JAR="postgresql-42.5.4.jar"

echo "Update Linux, dnf, & Instal Java 11"
sudo yum update -y
sudo dnf update
sudo dnf -y install wget
sudo dnf install java-11-openjdk java-11-openjdk-devel -y
java --version
javac --version

echo "Add Docker stuff"
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker
sudo usermod -aG docker rocky
sudo docker info

echo "Create keycloak directory"
sudo mkdir $KC_HOME                                     
sudo chown rocky:rocky $KC_HOME
ls -las $KC_HOME
sudo chown rocky:rocky -R $KC_HOME  

LOCAL_HOST_IP="127.0.0.1"
#sudo docker run -p 8443:8443 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:21.0.1 start-dev
cd /opt/keycloak/
touch Dockerfile
cat >Dockerfile <<EOF
FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak/
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://$LOCAL_HOST_IP:5432/keycloak
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=keycloak
ENV KC_HOSTNAME=aquinas.villasfoundation.com:8443
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
EOF

echo "Create Postgres modules directory & chown directories"
sudo mkdir -p /opt/keycloak/modules/system/layers/keycloak/com
sudo chown rocky:rocky -R /opt/keycloak/modules/
sudo ls -las /opt/keycloak/modules/system/layers/keycloak/com
sudo ls -las /opt/keycloak/modules/

echo "Install Postgres JDBC driver"
sudo wget -c https://jdbc.postgresql.org/download/$PSQL_JAR -P /opt/keycloak/modules/system/layers/keycloak/com
ls -las /opt/keycloak/modules/system/layers/keycloak/com
file /opt/keycloak/modules/system/layers/keycloak/com/$PSQL_JAR
touch /opt/keycloak/modules/system/layers/keycloak/com/module.xml
sudo chown rocky:rocky -R /opt/keycloak/modules/system/layers/keycloak/com

echo "create module local"
touch module.xml
cat >module.xml <<EOF
<?xml version="1.0" ?>
<module xmlns="urn:jboss:module:1.3" name="com.postgres">
 <resources>
  <resource-root path="postgresql-42.5.4.jar" />
 </resources>
 <dependencies>
  <module name="javax.api"/>
  <module name="javax.transaction.api"/>
 </dependencies>
</module>
EOF

echo "Copy to /opt/keycloak/modules/system/layers/keycloak/com/module.xml"
cp module.xml /opt/keycloak/modules/system/layers/keycloak/com/module.xml

echo "Install postgres on Rocky Linux/"
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
echo  "/dev/xvdf       /var/opt/keycloak        xfs     defaults,noatime        0       0  " >> /etc/fstab
sudo mount -a

echo "Configure hosts file #/etc/hosts"
sudo sed -i "s;127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4;127.0.0.1   localhost keycloak.local:8443 aquinas.villasfoundation.com:8443 localdomain4;g" /etc/hosts

echo "Javascript must be enabled to run this app https://stackoverflow.com/questions/8205369/installing-npm-on-aws-ec2"
dnf update -y
dnf install curl -y
curl -sL https://rpm.nodesource.com/setup_16.x | bash 
sudo dnf install -y nodejs
node -v
npm -v
python3 --version
java --version
javac --version

echo "Create models directory & Attempt model dir ebs volume mount on Keycloak instances"
sudo mkdir /var/opt/keycloak/
sudo mkfs -t xfs /dev/xvdf
sudo mount /dev/xvdf /var/opt/keycloak
sudo chown rocky:rocky /var/opt/keycloak/

echo "Check model-dir mount"
ls -las /var/opt/keycloak/
sudo lsblk -f
sudo file -s /dev/xvdf
sudo blkid

echo "Create postgres components"
sudo -u postgres psql << EOF
create database keycloak;
create user keycloak with encrypted password 'keycloak';
grant all privileges on database keycloak to keycloak;
ALTER DATABASE keycloak OWNER TO keycloak;
EOF
sudo systemctl restart postgresql
sudo systemctl status postgresql

#echo "Install Key Cloak"
#sudo wget https://github.com/keycloak/keycloak/releases/download/$VERSION/$KC_VERSION.tar.gz
#sudo tar -C /opt/keycloak -xzf $KC_VERSION.tar.gz
