output "service-eip" {
  value = "${aws_eip.service-eip.private_ip}"
}

output "service-dns" {
  value = "${aws_route53_record.service-dns.name}"
}

output "service_ami_id" {
  value = "${data.aws_ami.openservice.id}"
}
