resource "aws_lb" "this" {
  name                       = substr("${var.name_prefix}-alb", 0, 32)
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.security_group_id]
  subnets                    = var.subnet_ids
  drop_invalid_header_fields = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "blue" {
  name                 = substr("${var.name_prefix}-blue-tg", 0, 32)
  port                 = var.target_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-blue-tg"
    Slot = "blue"
  })
}

resource "aws_lb_target_group" "green" {
  name                 = substr("${var.name_prefix}-green-tg", 0, 32)
  port                 = var.target_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-green-tg"
    Slot = "green"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.enable_https && var.certificate_arn != null && var.redirect_http_to_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.enable_https && var.certificate_arn != null && var.redirect_http_to_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = var.active_slot == "green" ? aws_lb_target_group.green.arn : aws_lb_target_group.blue.arn
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.enable_https && var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.active_slot == "green" ? aws_lb_target_group.green.arn : aws_lb_target_group.blue.arn
  }
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.this.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.active_slot == "green" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
  }
}
