variable "build_key" {}
variable "cloud_size" {}
variable "domain" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "zone_id" {}



resource "aws_security_group" "vpn-sg" {
  name                   = "vpn-sg"
  vpc_id                 = "${var.vpc_id}"
  description            = "OpenVPN security group"
  tags {
    Name = "vpn-sg" }

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
    from_port            = 443
    to_port              = 443
    protocol             = "tcp"
    cidr_blocks          = ["0.0.0.0/0"]
  }
  ingress {
    from_port            = 943
    to_port              = 943
    protocol             = "tcp"
    cidr_blocks          = ["0.0.0.0/0"]
  }
  ingress {
    from_port            = 1194
    to_port              = 1194
    protocol             = "udp"
    cidr_blocks          = ["0.0.0.0/0"]
  }
  egress {
    from_port            = 0
    to_port              = 0
    protocol             = "-1"
    cidr_blocks          = ["0.0.0.0/0"]
  }
}

resource "aws_eip_association" "vpn-eip-assoc" {
  instance_id = "${aws_instance.openvpn.id}"
  allocation_id = "${aws_eip.vpn-eip.id}"
}

# get the latest ami for open vpn
data "aws_ami" "openvpn" {
    most_recent = true
    filter {
      name = "name"
      values = ["OpenVPN Access Server 2*"]
    }
    owners = ["573553919781"] # OpenVPN
}

resource "aws_instance" "openvpn" {
  ami = "${data.aws_ami.openvpn.id}"
  instance_type = "t2.small"
  key_name = "${var.build_key}"
  vpc_security_group_ids = ["${aws_security_group.vpn-sg.id}"]
  subnet_id = "${var.subnet_id}"
  tags {
    Name = "vpn"
  }
}

resource "aws_eip" "vpn-eip" {
  vpc       = true
}

resource "aws_route53_record" "vpn-dns" {
   zone_id = "${var.zone_id}"
   name = "vpn.${var.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_eip.vpn-eip.public_ip}"]
}
