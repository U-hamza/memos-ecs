# ECS cluster
resource "aws_ecs_cluster" "memos_cl" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}


# CloudWatch logs
resource "aws_cloudwatch_log_group" "memos_cloudwatch" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30
}


# Task definition
resource "aws_ecs_task_definition" "memos_task" {
  family = "${var.project_name}-task"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = var.task_execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = var.project_name
      image = "${var.repository_url}:${var.image_tag}"

      essential = true # true = if application crashes, ECS stops task

      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.memos_cloudwatch.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


# ECS service
resource "aws_ecs_service" "memos_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.memos_cl.id
  task_definition = aws_ecs_task_definition.memos_task.arn

  desired_count = 1 # Always keeps one container running, if crashes happen ECS auto opens another one"

  launch_type      = "FARGATE"
  platform_version = "LATEST"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200 # ecs can start new tasks, before stoping old deployment

  health_check_grace_period_seconds = 60 # allows time for ecs to see if application is healthy

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets = var.private_subnet_ids

    security_groups = [
      var.ecs_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn

    container_name = var.project_name

    container_port = 8081
  }

  depends_on = [
    aws_ecs_task_definition.memos_task
  ]
}
