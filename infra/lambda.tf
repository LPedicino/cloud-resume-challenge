# 1. El rol que permite a la Lambda ejecutar acciones
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

# 2. Política de permisos (DynamoDB + CloudWatch Logs)
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = aws_dynamodb_table.visitor_count.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 3. La función Lambda
resource "aws_lambda_function" "visitor_count_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "visitor_count_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  
  # Detecta cambios en el archivo .zip automáticamente
  source_code_hash = filebase64sha256("lambda_function.zip")
}