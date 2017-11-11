variable "build_key" {}
variable "cloud_size" {}
variable "domain" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "zone_id" {}



resource "aws_security_group" "service-sg" {
  name                   = "vpn-sg"
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

  # For OpenVPN Client Web Server and Admin Web UI
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
data "aws_ami" "ubuntu" {
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

# set up an a record and ip for the service
resource "aws_eip" "service-eip" {
    vpc = true
}

resource "aws_route53_record" "service-dns" {
    zone_id = "${var.zone_id}"
    name = "service.${var.domain}"
    type = "A"
    ttl = "300"
    records = ["${aws_eip.service-eip.private_ip}"]
}

resource "aws_instance" "service" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.build_key}"
    vpc_security_group_ids = ["${aws_security_group.}"]
    subnet_id = "${var.subnet_id}"
    tags {
        Name = "mock-service"
    }
}

output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}

output "instance_id" {
    value = "${aws_instance.service.id}"
}

output "instance_ip" {
    value = "${aws_instance.service.private_ip}"
}
