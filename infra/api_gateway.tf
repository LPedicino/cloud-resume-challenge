# 1. Creamos la API tipo REST
resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = "visitor-api"
  description = "API para el contador de visitas"
}

# 2. Definimos el recurso (la ruta /contador)
resource "aws_api_gateway_resource" "visitor_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "contador"
}

# 3. Definimos el método GET
resource "aws_api_gateway_method" "get_visitor" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.visitor_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# 4. Conectamos API Gateway con Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.visitor_resource.id
  http_method = aws_api_gateway_method.get_visitor.http_method
  integration_http_method = "POST" # Lambda siempre se invoca con POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_count_lambda.invoke_arn
}