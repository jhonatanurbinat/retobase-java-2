provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}


# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

# IAM Roles and Policies
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    },
  ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"

}

resource "aws_iam_role_policy_attachment" "ec2_service_role_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy_2" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ecs_execution_role_policy" {
  name        = "ECSEnExecutionRole_ecs_policy"
  description = "Policy for ECS Execution Role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "ec2:*",
          "ecs:*",
          "ecr:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "application-autoscaling:*",
          "logs:*",
          "tag:*",
          "resource-groups:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_execution_role_policy.arn
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "main" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_ssm_role.name
}


# Create Subnets
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_az1
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_az2
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_private_az1
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_private_az2
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}


# Create Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
}

# Create Route for Internet Gateway
resource "aws_route" "public_route_via_igw" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  depends_on = [
    aws_internet_gateway.main
  ]
}

# Associate Public Subnets with the Route Table
resource "aws_route_table_association" "pub_subnet_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "pub_subnet_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.main.id
}




# Security Group for ECS and Load Balancer
resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "load_balancer" {
  vpc_id = aws_vpc.main.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_2" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol    = "-1"  # Allow all traffic
  to_port           = 0
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_2" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# ECR Repository
resource "aws_ecr_repository" "main" {
  name = var.repository_name
}



# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}


# Create Launch Template
resource "aws_launch_template" "ecs_instance_template" {
  name = "${var.stack_name}-launch-template"


    iam_instance_profile {
      arn = aws_iam_instance_profile.main.arn
    }



    image_id      = var.ami_id  # Replace with the appropriate AMI ID
    instance_type = var.instance_type

    block_device_mappings {
    device_name = "/dev/xvda"
      ebs {
        volume_size = 30
        volume_type = "gp2"
      }
  }


    vpc_security_group_ids  = [aws_security_group.ecs.id]


    user_data = filebase64("ecs.sh")


    metadata_options {
      http_endpoint = "enabled"
    }
}

data "aws_caller_identity" "current" {}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs_instance_asg" {
  depends_on = [
    aws_ecs_cluster.main,
    aws_launch_template.ecs_instance_template
  ]

  launch_template {
    id = aws_launch_template.ecs_instance_template.id
    version = "$Latest"
  }



  min_size           = 1
  max_size           = 2
  desired_capacity   = 1
  vpc_zone_identifier = [
    aws_subnet.public_az1.id,
    aws_subnet.public_az2.id
  ]

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }


}


# Load Balancer
resource "aws_lb" "main" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]

  tags = {
    Name = aws_ecs_cluster.main.name
  }
}


# Target Group
resource "aws_lb_target_group" "main" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 9
    healthy_threshold   = 3
    unhealthy_threshold = 3
    port                = 80
    matcher = "200,201,204,301,302,304,400,401,403,404,405,408"
  }

}

# Listener for Load Balancer
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.main.arn
    }

}


resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_web_log_group" {
  name              = "/ecs/web"
  retention_in_days = 7
}



# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = "web"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "web"
    cpu       = var.ecs_task_cpu
    memory    = var.ecs_task_memory
    image     = "jhonatanurbinat/reto:latest"
    portMappings  = [{
      containerPort = 80
      hostPort     = 80
      protocol      = "tcp"
    }]
    log_configuration = {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/web"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "nginx"
      }
    }
  }])
}



# ECS Service
resource "aws_ecs_service" "main" {
  depends_on = [
    aws_lb_listener.main,
    aws_subnet.private_az1,
    aws_subnet.private_az2
  ]

  name            = "web"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  
  network_configuration {
      security_groups = [aws_security_group.service.id]
      subnets         = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
  }

  force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "web"
    container_port   = 80
  }

  health_check_grace_period_seconds = 30

}

# Security Group for ECS Service
resource "aws_security_group" "service" {
  name        = "service-security-group"
  description = "Security group for service"
  vpc_id      = aws_vpc.main.id
}

# Security Group Ingress Rule (allow ingress from the Load Balancer)
resource "aws_security_group_rule" "service_ingress_from_load_balancer" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"  # -1 means all protocols
  security_group_id = aws_security_group.service.id
  source_security_group_id = aws_security_group.load_balancer.id
}

