variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"  # Set a default region
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_public_az1" {
  default = "10.0.1.0/24"
}

variable "subnet_public_az2" {
  default = "10.0.2.0/24"
}

variable "subnet_private_az1" {
  default = "10.0.3.0/24"
}

variable "subnet_private_az2" {
  default = "10.0.4.0/24"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "ami_id" {
  default = "ami-05712a2b73d4ebafb"  # Update with the appropriate AMI ID
}

variable "ecs_task_cpu" {
  default = "256"
}

variable "ecs_task_memory" {
  default = "512"
}

variable "ecs_cluster_name" {
  default = "my-cluster"
}

variable "repository_name" {
  default = "test-repository"
}
