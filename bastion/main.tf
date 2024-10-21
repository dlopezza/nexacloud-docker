provider "aws" {
  region = "us-east-1"
}

data "local_file" "github_actions_ips" {
  filename = "${path.module}/github_actions_ips.txt"
}

resource "aws_security_group" "github_actions_sg" {
  name        = "github-actions-sg"
  description = "Allow SSH from GitHub Actions IP ranges"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  dynamic "ingress" {
    for_each = split("\n", trimspace(data.local_file.github_actions_ips.content)) # Ensures no empty lines
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-01e3c4a339a264cc9" # Make sure this AMI ID is valid for your region
  instance_type = "t2.micro" # Choose the appropriate instance type
  key_name      = "vockey" # Ensure this key pair exists in your AWS account
  security_groups = [aws_security_group.github_actions_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              # Install necessary packages for Terraform
              sudo yum install -y yum-utils shadow-utils
              sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              sudo yum -y install terraform
              
              # Verify the installation
              terraform -version
              EOF

  tags = {
    Name = "BastionHost"
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
