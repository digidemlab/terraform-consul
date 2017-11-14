# firewall for the loadbalancer
resource "aws_security_group" "lb-sg" {
  description = "controls access to the application loadbalancer"
  vpc_id = "${var.vpc_id}"
  name   = "service-lb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

## ALB
resource "aws_alb_target_group" "service" {
  name     = "${var.cloud_name}-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb" "service-alb" {
  name            = "service-alb"
  subnets         = ["${var.subnet_a_id}", "${var.subnet_b_id}"]
  security_groups = ["${aws_security_group.lb-sg.id}"]
}

resource "aws_alb_listener" "service-frontend" {
  load_balancer_arn = "${aws_lb.service-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.service.arn}"
    type             = "forward"
  }
}
# dns for the loadbalancer
