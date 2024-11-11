resource "aws_security_group" "this" {
  name   = "asg-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow HTTP request from Load Balancer"
    protocol        = "-1"
    from_port       = 0 #80
    to_port         = 0 #80
    #security_groups = [aws_security_group.elb_sg.id]
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description     = "Allow SSH from Anywhere"
    protocol        = "tcp"
    from_port       = 22   # SSH port
    to_port         = 22
    cidr_blocks     = ["0.0.0.0/0"]  # You can replace this with a more restricted IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "elb-template-${var.environment}"
  image_id      = "ami-01e3c4a339a264cc9"
  instance_type = "t3.micro"
  key_name = "vockey"
  user_data     = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras enable nginx1
    sudo yum install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "<h1>Hello World from $(hostname -f)</h1>" | sudo tee /usr/share/nginx/html/index.html
  EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnets_ids[0]
    security_groups             = [aws_security_group.this.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "elb-instance"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name             = "autoscaling-group-${var.environment}"
  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  target_group_arns = [aws_lb_target_group.this.arn]

  vpc_zone_identifier = var.subnets_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}
