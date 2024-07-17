output "api_key_id" {
  value = aws_api_gateway_api_key.this.id
}

output "api_key_arn" {
  value = aws_api_gateway_api_key.this.arn
}
