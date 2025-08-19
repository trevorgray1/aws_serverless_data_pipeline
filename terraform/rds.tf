resource "aws_db_subnet_group" "app_db_subnets" {
  name       = "app-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "app-db-subnet-group"
  }
}

resource "aws_db_instance" "app_db" {
  identifier             = "serverless-app-db"
  engine                 = "postgres"
  engine_version         = "15.13"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = "serverlessdb"
  username               = "appuser"
  password               = random_password.db_password.result
  parameter_group_name   = "default.postgres15"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.app_db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "serverless-app-db"
  }
}

resource "aws_security_group" "db_sg" {
  name   = "app-db-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda_sg.id] # only Lambdas can connect
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-db-sg"
  }
}

resource "aws_security_group" "lambda_sg" {
  name   = "app-lambda-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-lambda-sg"
  }
}

#############################
#############################
# Random password for RDS user
#############################
resource "random_password" "db_password" {
  length          = 16
  special         = true
  override_special = "!@#$%&*()-_=+"
}