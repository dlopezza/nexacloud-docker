provider "aws" {
  region = "us-east-1"
}

# data "local_file" "github_actions_ips" {
#   filename = "${path.module}/github_actions_ips.txt"
# }

resource "aws_security_group" "github_actions_sg" {
  name        = "github-actions-sg"
  description = "Allow SSH from GitHub Actions IP ranges"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-01e3c4a339a264cc9"
  instance_type = "t2.micro"
  key_name      = "githubKey"
  security_groups = [aws_security_group.github_actions_sg.name]
  iam_instance_profile = "LabInstanceProfile"

  user_data = file("${path.module}/script.sh")

  tags = {
    Name = "BastionHost"
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
