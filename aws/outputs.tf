output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "service_image_id" {
    value = "${module.service.image_id}"
}

output "zone_id" {
    value = "${data.aws_route53_zone.zone.id}"
}

output "service_subnet_id" {
    value = "${aws_subnet.service.id}"
}

output "data_subnet_id" {
    value = "${aws_subnet.data.id}"
}

output "public_a_subnet_id" {
    value = "${aws_subnet.public-a.id}"
}

output "public_b_subnet_id" {
    value = "${aws_subnet.public-b.id}"
}
