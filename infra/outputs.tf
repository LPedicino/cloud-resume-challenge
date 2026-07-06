output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

# Añade esto para ver la URL de tu API al terminar
output "api_url" {
  value = "${aws_api_gateway_stage.visitor_stage.invoke_url}/contador"
  description = "URL para acceder a la función del contador"
}