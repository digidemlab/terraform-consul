resource "aws_subnet" "service" {
  vpc_id                  = "${aws_vpc.small.id}"
  availability_zone       = "${var.consul_deploy_region}a"
  cidr_block              = "10.100.1.0/24"
  map_public_ip_on_launch = "false"
  tags {
    Name = "service"
  }
}

resource "aws_subnet" "data" {
  vpc_id                  = "${aws_vpc.small.id}"
  availability_zone       = "${var.consul_deploy_region}b"
  cidr_block              = "10.100.2.0/24"
  map_public_ip_on_launch = "false"
  tags {
    Name = "data"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.small.id}"
  availability_zone       = "${var.consul_deploy_region}a"
  cidr_block              = "10.100.3.0/24"
  map_public_ip_on_launch = "true"
  tags {
    Name = "public"
  }
}

resource "aws_db_subnet_group" "small-data" {
    name = "small-data"
    description = "subgroup for rds"
    subnet_ids = ["${aws_subnet.data.id}", "${aws_subnet.service.id}"]
    tags {
        Name = "data-group"
    }
}

output "service_subnet_id" {
    value = "${aws_subnet.service.id}"
}

output "data_subnet_id" {
    value = "${aws_subnet.data.id}"
}

output "public_subnet_id" {
    value = "${aws_subnet.public.id}"
}
