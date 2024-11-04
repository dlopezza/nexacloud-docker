#!/bin/bash
exec > /var/log/user-data.log 2>&1
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
terraform -version

sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
EOF