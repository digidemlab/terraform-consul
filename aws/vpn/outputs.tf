output "vpn-eip" {
  value = "${aws_eip.vpn-eip.public_ip}"
}

output "vpn-dns" {
  value = "${aws_route53_record.vpn-dns.name}"
}

output "vpn_ami_id" {
  value = "${data.aws_ami.openvpn.id}"
}
