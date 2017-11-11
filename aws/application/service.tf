variable "build_key" {}
variable "cloud_name" {}
variable "cloud_size" {}
variable "lb_name" {}
variable "service_deploy_region" {}
variable "subnet_id" {}
variable "vpc_id" {}

resource "aws_security_group" "service-sg" {
  name                   = "service-sg"
  vpc_id                 = "${var.vpc_id}"
  description            = "service security group"
  tags {
    Name = "service-sg"
  }

  ingress {
    from_port            = 0
    to_port              = 0
    protocol             = "-1"
    cidr_blocks          = ["10.100.0.0/16"]
  }

  ingress {
    from_port            = 22
    to_port              = 22
    protocol             = "tcp"
    cidr_blocks          = ["0.0.0.0/0"]
  }

  # For Openservice Client Web Server and Admin Web UI
  ingress {
    from_port            = 80
    to_port              = 80
    protocol             = "tcp"
    cidr_blocks          = ["0.0.0.0/0"]
  }
  egress {
    from_port            = 0
    to_port              = 0
    protocol             = "-1"
    cidr_blocks          = ["0.0.0.0/0"]
  }
}

# get the most recent ubuntu
data "aws_ami" "service" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_autoscaling_group" "service-asg" {
  availability_zones   = ["${var.service_deploy_region}-a"]
  name                 = "${var.cloud_name}-asg"
  max_size             = "1"
  min_size             = "1"
  desired_capacity     = "1"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.service-lc.name}"
  load_balancers       = ["${var.lb_name}"]
  vpc_zone_identifier  = ["${var.subnet_id}"]
  tag {
    key                 = "Name"
    value               = "service-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "service-lc" {
  name = "${var.cloud_name}-service-asg"
  image_id = "${data.aws_ami.service.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.service-sg.id}"]
  key_name = "${var.build_key}"
  lifecycle {
    create_before_destroy = true
  }
}
