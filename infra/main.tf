provider "aws" {
  region = "us-east-1"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group (Prod + Dev ortak)
resource "aws_security_group" "vinu_sg" {
  name        = "vinu-sg"
  description = "Allow SSH, Frontend (3000), Backend (4000)"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Frontend)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# PROD EC2 (main branch)

resource "aws_instance" "vinu_task" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 us-east-1
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.vinu_sg.id]

  tags = {
    Name = "vinu-task-prod"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io curl

              # Docker Compose plugin
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


# DEV EC2 (dev branch)

resource "aws_instance" "vinu_task_dev" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.vinu_sg.id]

  tags = {
    Name = "vinu-task-dev"
  }

  user_data = aws_instance.vinu_task.user_data
}
