# Descomentá estos outputs cuando compute.tf tenga los recursos aws_instance.
# Las IPs salen de Terraform — ya no las copiás a mano de la consola.
#
# output "public_instance_ip" {
#   description = "IP pública de la VM pública."
#   value       = aws_instance.public.public_ip
# }
#
# output "private_instance_ip" {
#   description = "IP privada de la VM privada."
#   value       = aws_instance.private.private_ip
# }
#
# output "ssh_public" {
#   description = "Comando para conectarse a la VM pública."
#   value       = "ssh -i ~/.ssh/labsuser.pem ec2-user@${aws_instance.public.public_ip}"
# }
