# =========================================================
# RDS SUBNET GROUP
# =========================================================

resource "aws_db_subnet_group" "mysql" {
  name = "${var.project_name}-mysql-subnet-group"

  subnet_ids = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]

  tags = {
    Name = "${var.project_name}-mysql-subnet-group"
  }
}

# =========================================================
# RDS MYSQL
# =========================================================

resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-mysql"

  engine = "mysql"

  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 3306

  db_subnet_group_name = aws_db_subnet_group.mysql.name

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  publicly_accessible = false

  backup_retention_period = 0

  multi_az = false

  deletion_protection = false

  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-mysql"
  }
}