# DB subnet group

resource "aws_db_subnet_group" "db" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}


#PostgreSQL db

resource "aws_db_instance" "sql_db" {
  identifier = "${var.project_name}-db"

  engine         = "postgres"
  engine_version = "17"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "memos"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [var.rds_security_group_id]

  publicly_accessible = false

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-db"
  }
}


# DB Secret

resource "aws_secretsmanager_secret" "memos_db" {
  name = "${var.project_name}/database"

  tags = {
    Name = "${var.project_name}-database-secret"
  }
}


resource "aws_secretsmanager_secret_version" "memos_db_secret" {
  secret_id = aws_secretsmanager_secret.memos_db.id

  secret_string = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.sql_db.address}:${aws_db_instance.sql_db.port}/${aws_db_instance.sql_db.db_name}?sslmode=disable"
}
