terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"
  key_name      = "aws_fr"
  count         = 5
  user_data     = <<-EOL
    #!/bin/bash
      sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
      sudo apt update
      sudo apt -y install docker-ce
      docker run hello-world
    EOL

}

resource "aws_security_group_rule" "default" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-123456"
}

module "stop_ec2_instance" {
  source                         = "diodonfrost/lambda-scheduler-stop-start/aws"
  name                           = "ec2_stop"
  cloudwatch_schedule_expression = "cron(0 1 * * ? *)"
  schedule_action                = "stop"
  autoscaling_schedule           = "false"
  ec2_schedule                   = "true"
  rds_schedule                   = "false"
  cloudwatch_alarm_schedule      = "false"
  scheduler_tag = {
    key   = "tostop"
    value = "true"
  }
}

module "start_ec2_instance" {
  source                         = "diodonfrost/lambda-scheduler-stop-start/aws"
  name                           = "ec2_start"
  cloudwatch_schedule_expression = "cron(0 5 * * ? *)"
  schedule_action                = "start"
  autoscaling_schedule           = "false"
  ec2_schedule                   = "true"
  rds_schedule                   = "false"
  cloudwatch_alarm_schedule      = "false"
  scheduler_tag = {
    key   = "tostop"
    value = "true"
  }
}