# get the most recent ubuntu
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_instance" "service" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"

    tags {
        Name = "mock-service"
    }
}

output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}

output "instance_id" {
    value = "${aws_instance.service.id}"
}

output "instance_ip" {
    value = "${aws_instance.service.private_ip}"
}