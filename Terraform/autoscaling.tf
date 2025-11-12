resource "aws_autoscaling_group" "web_asg" {
  name                 = "ecorise-asg"
  max_size             = 3
  min_size             = 1
  desired_capacity     = 2
  vpc_zone_identifier  = ["subnet-0aa351c501b72bd9d", "subnet-0c4ba5a006974b2b6"]
  target_group_arns    = [aws_lb_target_group.web_tg.arn]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "EcoRise-ASG-Instance"
    propagate_at_launch = true
  }
}

# Optional scaling policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type         = "ChangeInCapacity"
  scaling_adjustment      = 1
  cooldown                = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type         = "ChangeInCapacity"
  scaling_adjustment      = -1
  cooldown                = 300
}
