resource "aws_ecr_repository" "ecr" {
  name         = var.project_name
  force_delete = true

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.project_name
  }
}
