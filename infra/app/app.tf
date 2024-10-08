data "aws_elastic_beanstalk_solution_stack" "docker_stack" {
  most_recent = true
  name_regex  = "64bit Amazon Linux 2023 (.*) running Docker"
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for nexacloud beanstalk app"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elastic_beanstalk_application" "nexa-app" {
  name        = "Nexa cloud app"
  description = "Elastic Beanstalk Application for nexaCloud"

  appversion_lifecycle {
    service_role          = var.service_role
    max_count             = 5
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "my-app-version-${timestamp()}"
  application = aws_elastic_beanstalk_application.nexa-app.name
  bucket      = var.docker_bucket
  key         = var.dockerrun_key
}

resource "aws_elastic_beanstalk_environment" "nexa-env" {
  name                = "nexa-env"
  application         = aws_elastic_beanstalk_application.nexa-app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker_stack.name
  version_label       = aws_elastic_beanstalk_application_version.app_version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = var.instance_profile
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "vockey"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = var.private_subnet_id  # Use only the private subnet for EC2 instances
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = var.public_subnet_id  # Use only the public subnet for ELB
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.app_sg.id
  }

  dynamic "setting" {
  for_each = var.env_vars
  content {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = setting.key
    value     = setting.value
  }
}
}