output "vpc_id" {
  value = aws_vpc.main.id
}

output "frontend_instance_id" {
  value = aws_instance.frontend.id
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "frontend_public_dns" {
  value = aws_instance.frontend.public_dns
}

output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}

output "rds_address" {
  value = aws_db_instance.mysql.address
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "website_url" {
  value = "http://${aws_instance.frontend.public_ip}"
}