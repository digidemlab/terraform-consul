variable "build_key" {}
variable "cloud_name" {}
variable "cloud_size" {}
variable "db_password" {}
variable "domain" {}
variable "service_aws_access_key" {}
variable "service_aws_secret_key" {}
variable "service_deploy_region" {}
variable "vpns_enabled" {}

provider "aws" {
  access_key  = "${var.service_aws_access_key}"
  secret_key  = "${var.service_aws_secret_key}"
  region      = "${var.service_deploy_region}"
}

resource "aws_vpc" "vpc" {
  cidr_block            = "10.100.0.0/16"
  enable_dns_support    = "true"
  enable_dns_hostnames  = "true"
  tags {
    Name = "${var.cloud_name}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id  = "${aws_vpc.vpc.id}"
  tags    = {
    Name = "${var.cloud_name}-gw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gateway.id}"
}

resource "aws_route_table" "routes" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }
}

resource "aws_route_table_association" "route_assoc_a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.routes.id}"
}

resource "aws_route_table_association" "route_assoc_b" {
  subnet_id      = "${aws_subnet.public-b.id}"
  route_table_id = "${aws_route_table.routes.id}"
}

data "aws_route53_zone" "zone" {
  name = "${var.domain}"
}

module "service" {
  source = "./application"
  build_key = "${var.build_key}"
  cloud_name = "${var.cloud_name}"
  cloud_size = "${var.cloud_size}"
  lb_target_group_arn = "${module.loadbalancer.lb_target_group_arn}"
  service_deploy_region = "${var.service_deploy_region}"
  subnet_id = "${aws_subnet.service.id}"
  vpc_id = "${aws_vpc.vpc.id}"
}

module "loadbalancer" {
  source = "./loadbalancer"
  build_key = "${var.build_key}"
  cloud_name = "${var.cloud_name}"
  cloud_size = "${var.cloud_size}"
  domain = "${var.domain}"
  subnet_a_id = "${aws_subnet.public-a.id}"
  subnet_b_id = "${aws_subnet.public-b.id}"
  vpc_id = "${aws_vpc.vpc.id}"
  zone_id = "${data.aws_route53_zone.zone.id}"
}

module "database" {
  source = "./database"
  identifier = "${var.cloud_name}db"
  engine            = "postgres"
  engine_version    = "9.6.3"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false
  db_subnet_group_name = "${aws_db_subnet_group.data-group.name}"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word
  name = "${var.cloud_name}database"
  username = "administrator"
  password = "${var.db_password}"
  port     = "5432"
  multi_az = false
  publicly_accessible = false
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  # disable backups to create DB faster
  backup_retention_period = 0
  tags = {
    Environment = "dev"
  }
  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${var.cloud_name}finalsnap"
}
