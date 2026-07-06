# 1. El rol que permite a la Lambda escribir en DynamoDB
resource "aws_iam_role" "lambda_role" {
  name = "visitor_counter_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 2. Política de permisos para que la Lambda acceda a la tabla
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
      Resource = aws_dynamodb_table.visitor_count.arn
    }]
  })
}

# 3. La función Lambda (aquí cargaremos tu código Python)
resource "aws_lambda_function" "visitor_count_lambda" {
  filename      = "lambda_function.zip"
  function_name = "visitor_count_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
}