# =========================================================
# FRONTEND SECURITY GROUP
# =========================================================

resource "aws_security_group" "frontend" {

  name        = "${var.project_name}-frontend-sg"
  description = "Security group for frontend Nginx EC2"
  vpc_id      = aws_vpc.main.id

  # HTTP from Internet
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from your IP
  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-frontend-sg"
  }
}


# =========================================================
# BACKEND SECURITY GROUP
# =========================================================

resource "aws_security_group" "backend" {

  name        = "${var.project_name}-backend-sg"
  description = "Security group for Flask backend"
  vpc_id      = aws_vpc.main.id

  # Only frontend EC2 can access Flask on port 5000
  ingress {
    description     = "Flask API from frontend"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-backend-sg"
  }
}


# =========================================================
# DATABASE SECURITY GROUP
# =========================================================

resource "aws_security_group" "database" {

  name        = "${var.project_name}-db-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.main.id

  # Only backend EC2 can access MySQL on port 3306
  ingress {
    description     = "MySQL from backend"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}