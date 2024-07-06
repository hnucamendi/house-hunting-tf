resource "aws_dynamodb_table" "users" {
  name           = "UsersTable"
  billing_mode   = "PAY_PER_REQUEST"

  hash_key        = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "UsersTable"
  }
}

resource "aws_dynamodb_table" "projects" {
  name           = "ProjectsTable"
  billing_mode   = "PAY_PER_REQUEST"

  hash_key        = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "ProjectsTable"
  }
}