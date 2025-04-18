resource "aws_lb" "this" {
  name                             = var.name
  load_balancer_type               = "gateway"
  enable_cross_zone_load_balancing = true
  subnets                          = var.gwlb_subnet_ids
  ip_address_type = var.dual_stack ? "dualstack" : "ipv4"
}

resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.this.arn]
  depends_on                 = [aws_lb.this]
  supported_ip_address_types = var.dual_stack ? ["ipv4", "ipv6"] : ["ipv4"]

  tags = {
    Name = var.name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.name
  vpc_id      = var.vpc_id
  target_type = "instance"
  protocol    = "GENEVE"
  port        = "6081"

  deregistration_delay = var.deregistration_delay

  health_check {
    path     = "/unauth/php/health.php"
    port     = var.health_check_port
    protocol = "HTTP"

    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
  }
  target_failover {
    on_deregistration = var.target_failover
    on_unhealthy      = var.target_failover
  }
}
