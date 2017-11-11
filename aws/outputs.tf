output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "service_image_id" {
    value = "${module.service.image_id}"
}

output "zone_id" {
    value = "${data.aws_route53_zone.zone.id}"
}

output "vpn_ami" {
    value = "${module.vpn.vpn_ami_id}"
}

output "vpn_dns" {
    value = "${module.vpn.vpn-dns}"
}
