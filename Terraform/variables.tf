variable "region" {
  description = "AWS region to deploy resources"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  default     = "my-ec2-key"
}

variable "ecr_repo_url" {
  description = "ECR repository URL of the Docker image"
  default     = "207613818218.dkr.ecr.ap-south-1.amazonaws.com/html-website"
}

variable "security_group_name" {
  description = "Security group name for EC2 instance"
  default     = "jenkins-ec2-sg"
}
