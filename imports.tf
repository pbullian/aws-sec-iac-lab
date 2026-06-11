# ─────────────────────────────────────────────────────────────────────────────
# terraform import — adoptar la red que creaste A MANO (Terraform 1.5+)
# ─────────────────────────────────────────────────────────────────────────────
# Flujo (Lab "Importá tu red a Terraform"):
#   1. Completá los IDs en terraform.tfvars (vpc_id, *_subnet_id, etc.).
#   2. Descomentá los bloques `import {}` de abajo.
#   3. Generá el HCL automáticamente:
#        terraform plan -generate-config-out=network_generated.tf
#   4. Revisá lo generado, movelo a network.tf y borrá network_generated.tf.
#   5. Objetivo final:  terraform plan  →  "No changes."
#      (significa que tu código refleja EXACTAMENTE lo que hay en la nube)
#
# Empezá por la VPC y las subredes; después sumá IGW, NAT GW, route tables,
# NACLs y security groups (uno por uno, repitiendo el ciclo plan-generate).

# import {
#   to = aws_vpc.main
#   id = var.vpc_id            # ej: vpc-0abc123def456...
# }

# import {
#   to = aws_subnet.public
#   id = var.public_subnet_id  # ej: subnet-0aaa...
# }

# import {
#   to = aws_subnet.private
#   id = var.private_subnet_id # ej: subnet-0bbb...
# }

# TODO alumno: agregá bloques import {} para:
#   - aws_internet_gateway        (igw-...)
#   - aws_nat_gateway             (nat-...)
#   - aws_route_table  x2         (rtb-...)
#   - aws_network_acl  x2         (acl-...)
#   - aws_security_group x2+      (sg-...)
