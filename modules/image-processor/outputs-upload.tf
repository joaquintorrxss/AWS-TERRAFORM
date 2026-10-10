output "api_endpoint" {
  description = "Endpoint base de API Gateway"
  value       = aws_apigatewayv2_api.http.api_endpoint
}

output "upload_url" {
  description = "URL para cargar imagenes"
  value       = "${aws_apigatewayv2_api.http.api_endpoint}/upload"
}

output "upload_lambda_name" {
  description = "Nombre de la funcion Lambda Upload"
  value       = aws_lambda_function.upload.function_name
}