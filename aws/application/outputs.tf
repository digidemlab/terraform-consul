output "image_id" {
  value = "${data.aws_ami.service.id}"
}
