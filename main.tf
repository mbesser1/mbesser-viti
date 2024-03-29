provider "aws" {
  region = "us-east-1"
}

# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  vpc_id = "vpc-0924a92b8a509294d"
  # Ingress rule allowing SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id       = "vpc-0924a92b8a509294d"
  name_prefix  = "wordpress-db-"

  # Ingress rule allowing connections only from EC2 Security Group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

# Create EC2 Instance
resource "aws_instance" "wordpress_instance" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  key_name      = "test"  # Specified key pair
  subnet_id     = "subnet-0fd033afa7ff267ac"  # Subnet ID
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "WordPress-Instance"
  }
}

# Create a subnet group for RDS
resource "aws_db_subnet_group" "wordpressdb_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = ["subnet-0cf00432c3356cf5b", "subnet-0f3c9c3619eb0e2a3"]
}

# Create RDS MySQL instance
resource "aws_db_instance" "wordpressdb" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"  # Changed instance class to a supported one
  identifier           = var.database_name
  username             = var.database_user
  password             = var.database_password
  db_subnet_group_name = aws_db_subnet_group.wordpressdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "wordpress-rds"
  }
}

# Output: Public IP of the EC2 Instance
output "wordpress_public_ip" {
  value = aws_instance.wordpress_instance.public_ip
}

# Call userdata script
data "template_file" "user_data" {
  template = file("userdata.sh")
  vars = {
    db_username = var.database_user
    db_user_password = var.database_password
    db_name = var.database_name
    db_RDS = aws_db_instance.wordpressdb.endpoint
  }
}
