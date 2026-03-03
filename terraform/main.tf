provider "aws" {
  region = "us-east-1"
}

# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Allow SSH and App Port"

  ingress {
    description = "App Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------
# EC2 Instance (Ubuntu)
# ----------------------------
resource "aws_instance" "devops_ec2" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name      = "sotar"

  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install docker.io -y
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "devops-terraform-ec2"
  }
}

# ----------------------------
# Create Elastic IP
# ----------------------------
resource "aws_eip" "devops_eip" {
  domain = "vpc"
}

# ----------------------------
# Attach Elastic IP
# ----------------------------
resource "aws_eip_association" "devops_assoc" {
  instance_id   = aws_instance.devops_ec2.id
  allocation_id = aws_eip.devops_eip.id
}

# ----------------------------
# Output
# ----------------------------
output "elastic_ip" {
  value = aws_eip.devops_eip.public_ip
}
