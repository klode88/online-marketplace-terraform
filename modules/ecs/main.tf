variable "private_a_id" {}
variable "private_b_id" {}
variable "ecs_sg_id" {}
variable "product_tg_arn" {}
variable "cart_tg_arn" {}
variable "ecs_task_execution_role_arn" {}

############################################
# ECR Repositories
############################################

resource "aws_ecr_repository" "product_service" {
  name = "online-marketplace-product-service"
}

resource "aws_ecr_repository" "cart_service" {
  name = "online-marketplace-cart-service"
}

############################################
# ECS Cluster
############################################

resource "aws_ecs_cluster" "main" {
  name = "online-marketplace-cluster"
}

############################################
# Product Service
############################################

resource "aws_cloudwatch_log_group" "product_service" {
  name              = "/ecs/product-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "product_service" {
  family                   = "online-marketplace-product-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "product-service"
      image     = "${aws_ecr_repository.product_service.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.product_service.name
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "product_service" {
  name            = "online-marketplace-product-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.product_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_a_id, var.private_b_id]
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.product_tg_arn
    container_name   = "product-service"
    container_port   = 80
  }
}

############################################
# Cart Service
############################################

resource "aws_cloudwatch_log_group" "cart_service" {
  name              = "/ecs/cart-service"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "cart_service" {
  family                   = "online-marketplace-cart-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "cart-service"
      image     = "${aws_ecr_repository.cart_service.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cart_service.name
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "cart_service" {
  name            = "online-marketplace-cart-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.cart_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_a_id, var.private_b_id]
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.cart_tg_arn
    container_name   = "cart-service"
    container_port   = 80
  }
}

############################################
# ECS Auto Scaling
############################################

resource "aws_appautoscaling_target" "product_ecs" {
  max_capacity       = 3
  min_capacity       = 1
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.product_service.name}"
}

resource "aws_appautoscaling_policy" "product_cpu_policy" {
  name               = "product-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.product_ecs.service_namespace
  scalable_dimension = aws_appautoscaling_target.product_ecs.scalable_dimension
  resource_id        = aws_appautoscaling_target.product_ecs.resource_id

  target_tracking_scaling_policy_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "cart_ecs" {
  max_capacity       = 3
  min_capacity       = 1
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.cart_service.name}"
}

resource "aws_appautoscaling_policy" "cart_cpu_policy" {
  name               = "cart-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.cart_ecs.service_namespace
  scalable_dimension = aws_appautoscaling_target.cart_ecs.scalable_dimension
  resource_id        = aws_appautoscaling_target.cart_ecs.resource_id

  target_tracking_scaling_policy_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

############################################
# Outputs
############################################

output "product_ecr_repository_url" {
  value = aws_ecr_repository.product_service.repository_url
}

output "cart_ecr_repository_url" {
  value = aws_ecr_repository.cart_service.repository_url
}