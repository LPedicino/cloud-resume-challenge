# 1. API tipo REST
resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = "visitor-api"
  description = "API para el contador de visitas"
}

# 2. Recurso /contador
resource "aws_api_gateway_resource" "visitor_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "contador"
}

# 3. Método GET
resource "aws_api_gateway_method" "get_visitor" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.visitor_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# 4. Integración con Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_api.id
  resource_id             = aws_api_gateway_resource.visitor_resource.id
  http_method             = aws_api_gateway_method.get_visitor.http_method
  integration_http_method = "POST" 
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_count_lambda.invoke_arn
}

# 5. PERMISO CRÍTICO: Permitir que el API Gateway invoque la Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_count_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/*"
}

# 6. Deployment (Necesario para que la API esté "viva")
resource "aws_api_gateway_deployment" "visitor_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
}

# 7. Stage (Para acceder a la URL, ej: .../prod/contador)
resource "aws_api_gateway_stage" "visitor_stage" {
  deployment_id = aws_api_gateway_deployment.visitor_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  stage_name    = "prod"
}