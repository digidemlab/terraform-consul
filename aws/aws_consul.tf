variable "consul_aws_access_key" {}
variable "consul_aws_secret_key" {}
variable "consul_deploy_region" {}
variable "build_key" {}
variable "domain" {}
variable "with_vpn" {}

provider "aws" {
  access_key  = "${var.consul_aws_access_key}"
  secret_key  = "${var.consul_aws_secret_key}"
  region      = "${var.consul_deploy_region}"
}

resource "aws_vpc" "small" {
  cidr_block            = "10.100.0.0/16"
  enable_dns_support    = "true"
  enable_dns_hostnames  = "true"
  tags {
    Name = "small"
  }
}

resource "aws_internet_gateway" "small_gw" {
  vpc_id  = "${aws_vpc.small.id}"
  tags    = {
    Name = "small-gw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.small.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.small_gw.id}"
}

module "service" {
  source = "./application"
}

output "small_vpc_id" {
    value = "${aws_vpc.small.id}"
}

output "consul_image_id" {
    value = "${module.service.image_id}"
}

output "consul_instance_id" {
    value = "${module.service.instance_id}"
}

output "consul_ip" {
    value = "${module.service.instance_ip}"
}
