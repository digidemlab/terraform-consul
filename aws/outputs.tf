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

output "zone_id" {
    value = "${data.aws_route53_zone.zone.id}"
}

output "vpn_ami" {
    value = "${module.vpn.vpn_ami_id}"
}
