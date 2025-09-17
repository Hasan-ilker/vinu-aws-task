provider "aws" {
  region = "us-east-1"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "vinu_sg" {
  name        = "vinu-sg"
  description = "Allow SSH and HTTP (Nginx proxy)"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Nginx üzerinden erişim)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tüm çıkışlara izin
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "vinu_task" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 us-east-1
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.vinu_sg.id]

  tags = {
    Name = "vinu-task"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io curl

              # Docker Compose plugin kurulumu
              DOCKER_CONFIG=$${DOCKER_CONFIG:-/usr/lib/docker}
              mkdir -p $DOCKER_CONFIG/cli-plugins
              curl -SL https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64 \
                   -o $DOCKER_CONFIG/cli-plugins/docker-compose
              chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

              systemctl enable docker
              systemctl start docker

              usermod -aG docker ubuntu
              EOF
}

