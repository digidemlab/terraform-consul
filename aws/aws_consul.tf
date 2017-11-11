variable "build_key" {}
variable "cloud_name" {}
variable "cloud_size" {}
variable "consul_aws_access_key" {}
variable "consul_aws_secret_key" {}
variable "consul_deploy_region" {}
variable "domain" {}
variable "vpns_enabled" {}


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

data "aws_route53_zone" "zone" {
  name = "${var.domain}"
}

module "service" {
  source = "./application"
  build_key = "${var.build_key}"
  cloud_size = "${var.cloud_size}"
  domain = "${var.domain}"
  subnet_id = "${aws_subnet.service.id}"
  vpc_id = "${aws_vpc.small.id}"
  zone_id = "${data.aws_route53_zone.zone.id}"
}

module "database" {
  source = "./database"
  build_key = "${var.build_key}"
  cloud_size = "${var.cloud_size}"
  domain = "${var.domain}"
  subnet_id = "${aws_subnet.data.id}"
  vpc_id = "${aws_vpc.small.id}"
  zone_id = "${data.aws_route53_zone.zone.id}"
}

module "nat" {
  source = "./nat"
  build_key = "${var.build_key}"
  cloud_size = "${var.cloud_size}"
  domain = "${var.domain}"
  subnet_id = "${aws_subnet.public.id}"
  vpc_id = "${aws_vpc.small.id}"
  zone_id = "${data.aws_route53_zone.zone.id}"
}

module "vpn" {
  source = "./vpn"
  build_key = "${var.build_key}"
  cloud_size = "${var.cloud_size}"
  domain = "${var.domain}"
  subnet_id = "${aws_subnet.public.id}"
  vpc_id = "${aws_vpc.small.id}"
  zone_id = "${data.aws_route53_zone.zone.id}"
}

module "loadbalancer" {
  source = "./loadbalancer"
  build_key = "${var.build_key}"
  cloud_size = "${var.cloud_size}"
  domain = "${var.domain}"
  subnet_id = "${aws_subnet.public.id}"
  vpc_id = "${aws_vpc.small.id}"
  zone_id = "${data.aws_route53_zone.zone.id}"
}
