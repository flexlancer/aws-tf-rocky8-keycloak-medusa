### AWS Terraform Keycloak for cluster running Docker mode
###### After initial Docker provisioning, configure_kc_prod.sh
Setup with AWS free tier eligible 30 GB HD and t2.micro ec2 instance
```
/etc/hosts
keycloak.local
aquinas.villasfoundation.com

Keycloak CLI commands:
bin/kc.sh build --db postgres #try this one --transaction-xa-enabled=false
bin/kc.sh start --optimized --hostname-strict-backchannel=true --https-protocols=TLSv1.3,TLSv1.2 --hostname-strict-https=true 

K3yCl0@kD1sc0ur53
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
chmod 600 /home/mechanic/.kube/config

pip install aws-mfa
aws_mfa_device = arn:aws:iam::271192833499:mfa/GoogleAuthQCS

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
git remote add origin git@github.com:qcloud-systems/hugo-audio-quintessentialcloud-com.git
Create Git Repo via GUI at github.com:

Add remote repo from local shell command line:  
git remote add origin git@github.com:qcloud-systems/aws-tf-keycloak.git
git checkout -b 20230226-pr
git add . 
git rm -r .terraform/*

If problems on merge to main branch (default Github branch use the following:
git checkout master  
git branch main master -f    
git checkout main  
git push origin main -f
```
###### References:
# https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 16
node -e "console.log('Running Node.js ' + process.version)"
```
