# =========================================================
# FRONTEND EC2
# Nginx will run here
# =========================================================

resource "aws_instance" "frontend" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  subnet_id = aws_subnet.public_a.id

  vpc_security_group_ids = [
    aws_security_group.frontend.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.backend.name

  metadata_options {
    http_tokens = "required"
  }

  user_data = <<-EOF
    #!/bin/bash

    # Update system
    dnf update -y

    # Install Git and Nginx
    dnf install -y git nginx

    # Enable Nginx
    systemctl enable nginx
    systemctl start nginx

    # Clone application
    cd /opt

    git clone https://github.com/CloudTechDevOps/aws-ecomerce-Application-Multiple-services.git

    # Remove default Nginx page
    rm -rf /usr/share/nginx/html/*

    # Copy frontend files
    cp -r /opt/aws-ecomerce-Application-Multiple-services/frontend/* /usr/share/nginx/html/

    # Copy files from frontend/main if the directory exists
    if [ -d /opt/aws-ecomerce-Application-Multiple-services/frontend/main ]; then
      cp -r /opt/aws-ecomerce-Application-Multiple-services/frontend/main/* /usr/share/nginx/html/
    fi

    # Create Nginx reverse proxy configuration
    cat > /etc/nginx/conf.d/ecommerce.conf <<'NGINX'
    server {
        listen 80;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        location = /api {
            proxy_pass http://${aws_instance.backend.private_ip}:5000/api;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /api/ {
            proxy_pass http://${aws_instance.backend.private_ip}:5000/api/;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
    NGINX

    # Remove default Nginx config if present
    rm -f /etc/nginx/conf.d/default.conf

    # Test Nginx configuration
    nginx -t

    # Restart Nginx
    systemctl restart nginx
  EOF

  depends_on = [
    aws_instance.backend
  ]

  tags = {
    Name = "${var.project_name}-frontend"
  }
}

# =========================================================
# BACKEND EC2
# Flask will run here
# =========================================================

resource "aws_instance" "backend" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  subnet_id = aws_subnet.private_a.id

  vpc_security_group_ids = [
    aws_security_group.backend.id
  ]

  # NO public IP
  associate_public_ip_address = false

  # Use SSM instead of exposing SSH
  iam_instance_profile = aws_iam_instance_profile.backend.name

  # Key is not needed for the private instance,
  # but we can still associate the existing key pair.
  key_name = var.key_name

  metadata_options {
    http_tokens = "required"
  }

  user_data = <<-EOF
    #!/bin/bash

    # Update system
    dnf update -y

    # Install packages required by the application
    dnf install -y git python3 python3-pip mariadb105 nodejs npm

    # Clone application
    cd /opt

    git clone https://github.com/CloudTechDevOps/aws-ecomerce-Application-Multiple-services.git

    # Enter backend directory
    cd /opt/aws-ecomerce-Application-Multiple-services/backend

    # Create Python virtual environment
    python3 -m venv venv

    # Activate virtual environment
    source venv/bin/activate

    # Update pip
    pip install --upgrade pip

    # Install application dependencies
    pip install -r requirements.txt

    # Make sure SSM Agent is enabled
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

  EOF

  # Private EC2 needs NAT for package downloads and GitHub access.
  depends_on = [
    aws_route.private_to_nat
  ]

  tags = {
    Name = "${var.project_name}-backend"
  }
}