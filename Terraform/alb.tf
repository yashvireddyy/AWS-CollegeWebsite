resource "aws_lb" "web_alb" {
  name               = "ecorise-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = ["subnet-0aa351c501b72bd9d", "subnet-0c4ba5a006974b2b6"]
}

resource "aws_lb_target_group" "web_tg" {
  name     = "ecorise-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0cdc07d84991fc000"
  health_check {
    path = "/"
    interval = 30
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

output "load_balancer_dns" {
  description = "DNS of Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

