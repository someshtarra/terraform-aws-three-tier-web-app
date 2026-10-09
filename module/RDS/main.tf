
resource "aws_db_subnet_group" "db_subnet" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnets

  tags = {
    Name = "3-TIER-DB-SUBNET-GROUP"
  }

}

resource "aws_db_instance" "db_instance" {
  identifier             = var.db_identifier
  engine                 = var.db_engine
  allocated_storage      = var.db_storage
  storage_type           = var.db_storage_type
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = var.db_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name

  tags = {
    Name = var.db_identifier
  }

}