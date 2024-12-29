### AWS Terraform Keycloak for cluster running Docker mode
###### After initial Docker provisioning, configure_kc_prod.sh
Setup with AWS free tier eligible 30 GB HD and t2.micro ec2 instance
```
/etc/hosts
keycloak.local
localhost

Keycloak CLI commands:
bin/kc.sh build --db postgres #try this one --transaction-xa-enabled=false
bin/kc.sh start --optimized --hostname-strict-backchannel=true --https-protocols=TLSv1.3,TLSv1.2 --hostname-strict-https=true 
```
###### Dependencies: 
```
echo $SHELL
/bin/bash/
touch ~/.bash_profile
https://linuxhint.com/simple-guide-to-create-open-edit-bash-profile/

aws --version
https://docs.aws.amazon.com/cli/v1/userguide/install-linux.html#install-linux-pip

brew version
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/mechanic/.bash_profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install tfenv
tfenv version

kubectl version

helm version
chmod 600 /home/<user>/.kube/config

pip install aws-mfa
aws_mfa_device = arn:aws:iam:::mfa/GoogleAuth

# brew install aws-vault
https://github.com/99designs/aws-vault

go --version
sudo rm -rf /usr/bin/go
sudo mv /lib/go-1.13/bin/go /lib/go-1.13/bin/go.old
brew install go

https://github.com/mrparkers/terraform-provider-keycloak
https://www.keycloak.org/docs/11.0/getting_started/

brew install tfsec
https://github.com/aquasecurity/tfsec
```
###### Git:
```
git init
git remote add origin git@github.com:<username>/<repo-name>.git
Create Git Repo via GUI at github.com:

Add remote repo from local shell command line:  
git remote add origin git@github.com:<username>/<repo-name>.git
git checkout -b 20240726-pr
git add . 
git rm -r .terraform/*

If problems on merge to main branch (default Github branch use the following:
git checkout master  
git branch main master -f    
git checkout main  
git push origin main -f
```
###### References:
###### https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 16
node -e "console.log('Running Node.js ' + process.version)"
```

### AWS Quarkus environment with Java 11 on Ubuntu 20 (Terraform version 1.3.7)

Install Quarkus script (included Docker)

Install kubectl script

Init Ansible script
   
###### LOCAL: Windows 10 OS - Subsystem for Linux (WSL2.0) with Ubuntu 20 using Visual Studio Code
```
Install linuxbrew [https://docs.brew.sh/Homebrew-on-Linux] 
Install tfenv via linuxbrew [https://github.com/tfutils/tfenv] 
Install python3/boto sudo apt install python3-pip, Upgrade the awscli or else boto will give errors later (pip3 install --upgrade awscli)

aws ec2 describe-images --owners 099720109477 --query 'sort_by(Images, &CreationDate)[].[CreationDate,Name,ImageId]' --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu*" --region eu-north-1 --output table

aws ec2 describe-images --image-ids ami-09186119cd81dc944 --region eu-north-1 | jq -r '.Images[0].OwnerId'

Optional
sudo apt-get install putty-tools
cp /mnt/c/Users/Operator/Downloads/ubuntu20_eucentral1.ppk  ~/
puttygen ubuntu20_eucentral1.ppk -O private-openssh -o ubuntu20_eucentral1.pem
chmod 400 ubuntu20_eucentral1.pem
ssh -i ubuntu20_eucentral1.pem ubuntu@serverip

install awscli (aws-cli/1.18.69 Python/3.8.10 Linux/5.10.16.3-microsoft-standard-WSL2 botocore/1.16.19) (aws configure) 
```
###### References: 
###### https://adamtheautomator.com/terraform-vpc/#Building_the_Terraform_Configuration_for_an_AWS_VPC
###### https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html#default-vpc-components
###### https://medium.com/on-the-cloud/one-click-environment-creation-with-terraform-ansible-in-under-10-6e8d9284f60
###### https://medium.com/appgambit/terraform-aws-vpc-with-private-public-subnets-with-nat-4094ad2ab331
###### https://faun.pub/building-repeatable-infrastructure-with-terraform-and-ansible-on-aws-3f082cd398ad
###### https://www.linuxtechi.com/how-to-install-ansible-on-ubuntu/
###### https://dev.to/mariehposa/how-to-deploy-an-application-to-aws-ec2-instance-using-terraform-and-ansible-3e78
###### https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-20-04

###### https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
###### https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux
###### https://epma.medium.com/how-to-install-jenkins-on-ubuntu-20-04-lts-dc62bba5c8f3
###### https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
###### https://quarkus.io/guides/security-openid-connect-web-authentication

GraalVM dependencies
###### https://quarkus.io/guides/building-native-image

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04

https://www.hackerxone.com/2022/06/05/steps-to-install-configure-keycloak-on-ubuntu-20-04-lts/



Install kubectl
https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux

Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

Install Prometheus Operator
https://grafana.com/docs/grafana-cloud/kubernetes/prometheus/prometheus_operator/
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml
kubectl apply -f




### AWS cloud environment architecture plan overview
```
Local Network setup: 
IP Address:	           10.7.0.0
Network Address:	   10.7.0.0
Usable Host IP Range:  10.7.0.1 - 10.7.255.254
Broadcast Address:	   10.7.255.255
Total Number of Hosts: 65,536
Number of Usable Hosts:65,534
Subnet Mask:	       255.255.0.0
Wildcard Mask:	       0.0.255.255
Binary Subnet Mask:	   11111111.11111111.00000000.00000000
IP Class:	           B
CIDR Notation:	       /16
IP Type:	           Private
Short:	               10.7.0.0 /16 

terraform.tfvars
main_vpc_cidr         = "10.7.0.0/16"
public_subnet_1_cidr  = "10.7.1.0/24"
public_subnet_2_cidr  = "10.7.2.0/24"
public_subnet_3_cidr  = "10.7.3.0/24"
private_subnet_1_cidr = "10.7.10.0/24"
private_subnet_2_cidr = "10.7.11.0/24"
private_subnet_3_cidr = "10.7.12.0/24"
region                = "eu-central-1" 
```

- Install Local Dependencies: 
    - Install linuxbrew [https://docs.brew.sh/Homebrew-on-Linux] 
    - Install brew install tfenv [https://github.com/tfutils/tfenv] 
    - Install terraform via tfenv install 1.0.5 
    - Install sudo apt install awscli (aws-cli/1.18.69 Python/3.8.10 Linux/5.10.16.3-microsoft-standard-WSL2 botocore/1.16.19) (aws configure) 
    - Install python3/boto sudo apt install python3-pip, Upgrade the awscli or else boto will give errors later (pip3 install --upgrade awscli)


### Terraform AWS infrastructure Resources:
     - create security group
     - create Ubuntu 20 ec2 instance region a
     - create Ubuntu 20 ec2 instance region b
     - create public route table
     - create public route table association
     - create internet gateway
     - create public subnet a
     - create private subnet a
     - create private route table

```
sudo apt-get install putty-tools
cp /mnt/c/Users/Operator/Downloads/ubuntu20_eucentral1.ppk  ~/
puttygen ubuntu20_eucentral1.ppk -O private-openssh -o ubuntu20_eucentral1.pem
chmod 400 ubuntu20_eucentral1.pem
ssh -i ubuntu20_eucentral1.pem ubuntu@serverip
```

Ansible part :
    create a directory /data where we can mount our ebs voulme
    create partition of voulme
    format partition with ext4
    mount it at /data
    install docker and git
    start docker service and enable it
    pull jenkins image from dockerhub
    launch a new container with jenkins image
    pull httpd image from dockerhub
    launch a new cointainer with httpd image

Docker part :
    with ansible we will pull httpd and jenkins image from docker hub
    lauch container with jenkins image with -p 8080:8080 and -v /data/:/var/jenkins_home
    launch containers with httpd image with -p 80:80 and -v /data/workspace/website/:/usr/local/apache2/htdocs/

### AWS AMI searching

```
aws ec2 describe-images --owners 099720109477 --query 'sort_by(Images, &CreationDate)[].[CreationDate,Name,ImageId]' --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu*" --region eu-central-1 --output table

aws ec2 describe-images --image-ids ami-05034a7fcbfe5d5af --region eu-central-1 | jq -r '.Images[0].OwnerId'
```   
###### LOCAL MACHINE / UBUNTU 20 SHELL DEVELOPER ENVIRONMENT SETTINGS: Windows 10 OS running Windows Subsystem for Linux (WSL2.0) with Ubuntu 20 using Visual Studio Code
###### References: 
###### https://adamtheautomator.com/terraform-vpc/#Building_the_Terraform_Configuration_for_an_AWS_VPC
###### https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html#default-vpc-components
###### https://medium.com/on-the-cloud/one-click-environment-creation-with-terraform-ansible-in-under-10-6e8d9284f60
###### https://medium.com/appgambit/terraform-aws-vpc-with-private-public-subnets-with-nat-4094ad2ab331
###### https://faun.pub/building-repeatable-infrastructure-with-terraform-and-ansible-on-aws-3f082cd398ad
###### https://www.linuxtechi.com/how-to-install-ansible-on-ubuntu/
###### https://dev.to/mariehposa/how-to-deploy-an-application-to-aws-ec2-instance-using-terraform-and-ansible-3e78
