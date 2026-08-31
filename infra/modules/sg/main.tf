# ALB sg
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}


# ALB Inbound
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80

  cidr_ipv4 = "0.0.0.0/0"
}


resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "0.0.0.0/0"
}

# ALB Outbound
resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}


# ECS sg
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "ECS Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

# ECS Inbound
resource "aws_vpc_security_group_ingress_rule" "ecs_inbound" {
  security_group_id = aws_security_group.ecs.id

  ip_protocol = "tcp"
  from_port   = 8081
  to_port     = 8081

  referenced_security_group_id = aws_security_group.alb.id # This only allows ALB to talk to ECS tasks
}



# ECS Outbound
resource "aws_vpc_security_group_egress_rule" "ecs_outbound" {
  security_group_id = aws_security_group.ecs.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}


# RDS sg
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for Memos RDS database"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# RDS inbound
resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ecs.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

# RDS outbound
resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

