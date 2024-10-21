#!/bin/bash
exec > /var/log/user-data.log 2>&1
echo "Starting Terraform installation"
sudo yum install -y yum-utils shadow-utils
echo "Adding HashiCorp repository"
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
echo "Installing Terraform"
sudo yum -y install terraform
echo "Terraform installation complete"
terraform -version
EOF