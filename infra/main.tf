module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  availability_zone_1   = var.availability_zone_1
  availability_zone_2   = var.availability_zone_2
}


data "aws_ecr_repository" "ecr" {
  name = var.project_name
}


module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}


module "security_groups" {
  source = "./modules/sg"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  certificate_arn       = module.acm.certificate_arn
}

module "acm" {
  source = "./modules/acm"

  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
}


module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  aws_region   = var.aws_region

  repository_url          = data.aws_ecr_repository.ecr.repository_url
  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn

  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_security_group_id

  target_group_arn = module.alb.target_group_arn

  image_tag = var.image_tag

  depends_on = [
    module.alb
  ]
}


module "route53" {
  source = "./modules/route53"

  hosted_zone_id = var.hosted_zone_id
  domain_name    = var.domain_name

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

  depends_on = [
    module.alb
  ]
}
