resource "aws_launch_template" "web_lt" {
  name_prefix   = "ecrise-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              sleep 10
              REGION=${var.region}
              REPO=${var.ecr_repo_url}
              aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPO
              docker pull $REPO
              docker run -d --name college-website -p 80:80 $REPO
              EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.web_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "EcoRise-AutoScaled-EC2"
    }
  }
}
