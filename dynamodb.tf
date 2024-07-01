resource "aws_dynamodb_table" "users" {
  name           = "UsersTable"
  billing_mode   = "PAY_PER_REQUEST"

  hash_key        = "id"
  range_key       = "project_id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "project_id"
    type = "S"
  }

  tags = {
    Name = "UsersTable"
  }
}


# resource "aws_dynamodb_table" "criteria" {
#   name           = "CriteriaTable"
#   billing_mode   = "PAY_PER_REQUEST"

#   hash_key       = "project_id"
#   range_key      = "criteria_id"

#   attribute {
#     name = "project_id"
#     type = "S"
#   }

#   attribute {
#     name = "criteria_id"
#     type = "S"
#   }

#   tags = {
#     Name = "CriteriaTable"
#   }
# }

# resource "aws_dynamodb_table" "ratings" {
#   name           = "RatingsTable"
#   billing_mode   = "PAY_PER_REQUEST"

#   hash_key       = "project_id"
#   range_key      = "rating_id"

#   attribute {
#     name = "project_id"
#     type = "S"
#   }

#   attribute {
#     name = "rating_id"
#     type = "S"
#   }

#   tags = {
#     Name = "RatingsTable"
#   }
# }

