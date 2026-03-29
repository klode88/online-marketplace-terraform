variable "vpc_id" {}
variable "public_a_id" {}
variable "public_b_id" {}
variable "alb_sg_id" {}

resource "aws_lb" "app_alb" {
  name               = "online-marketplace-dev-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [var.alb_sg_id]
  subnets         = [var.public_a_id, var.public_b_id]
}

resource "aws_lb_target_group" "product_tg" {
  name_prefix = "omtp-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "cart_tg" {
  name_prefix = "omtc-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_tg.arn
  }
}

resource "aws_lb_listener_rule" "cart_path" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cart_tg.arn
  }

  condition {
    path_pattern {
      values = ["/cart", "/cart/*"]
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "product_tg_arn" {
  value = aws_lb_target_group.product_tg.arn
}

output "cart_tg_arn" {
  value = aws_lb_target_group.cart_tg.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

output "cart_listener_rule_arn" {
  value = aws_lb_listener_rule.cart_path.arn
}