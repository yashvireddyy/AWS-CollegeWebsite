output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "ec2_instance_id" {
  description = "Instance ID"
  value       = aws_instance.web.id
}

output "alb_dns_name" {
  description = "DNS name of Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

