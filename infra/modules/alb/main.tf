# ALB
resource "aws_lb" "memos_alb" {
  name               = "${var.project_name}-alb"
  internal           = false # false due to internet facing ALB
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name        = "${var.project_name}-tg"
  port        = 8081
  protocol    = "HTTP"
  target_type = "ip" # Using Fargate so IP needed

  vpc_id = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# HTTP Listner
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.memos_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listner

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.memos_alb.arn

  port     = 443
  protocol = "HTTPS"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
