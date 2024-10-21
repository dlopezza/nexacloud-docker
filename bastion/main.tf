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
    for_each = split("\n", trimspace(data.local_file.github_actions_ips.content))
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [trimspace(ingress.value)]
    }
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-01e3c4a339a264cc9"
  instance_type = "t2.micro"
  key_name      = "vockey"
  security_groups = [aws_security_group.github_actions_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y yum-utils shadow-utils
              sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              sudo yum -y install terraform
              terraform -version
              EOF

  tags = {
    Name = "BastionHost"
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
