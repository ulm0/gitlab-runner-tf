output "public_key" { value = local.public_key }
output "private_key" { value = local.private_key }
output "public_ip" { value = aws_instance.runner.public_ip }
output "public_dns" { value = aws_instance.runner.public_dns }
