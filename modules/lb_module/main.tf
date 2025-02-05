resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = var.lb_type
  subnets            = var.lb_subnets

  enable_deletion_protection = var.lb_enable_deletion_protection
  security_groups            = var.lb_security_groups

  tags = {
    Name = var.lb_name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [aws_lb.this]
}


resource "aws_lb_target_group" "this" {
  name        = var.lb_name
  port        = var.lb_target_group_port
  protocol    = var.lb_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.lb_target_group_type
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }

  depends_on = [aws_lb.this]
}

locals {
  instance_ids = { for idx, attachment in var.lb_target_group_attachment_instance_ids : idx => attachment }
}
resource "aws_lb_target_group_attachment" "this" {
  for_each         = local.instance_ids
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = var.lb_target_group_attachment_port

  depends_on = [aws_lb_target_group.this]
}

