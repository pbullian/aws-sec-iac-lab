# ─────────────────────────────────────────────────────────────────────────────
# terraform import — adoptar la red que creaste A MANO (Terraform 1.5+)
# ─────────────────────────────────────────────────────────────────────────────
# La config de los recursos ya está en network.tf. Acá sólo enlazás cada recurso
# con el ID real que anotaste de la consola (o sacaste con `aws ec2 describe-*`).
#
# Reemplazá cada REPLACE_* por tu ID. Después:
#   terraform init
#   terraform plan     # "N to import, X to change" (X = sólo tags → OK)
#   terraform apply    # importa + converge tags (NADA se recrea)
#   terraform plan     # → "No changes." ✅
#
# NO uses `-generate-config-out`: para estos recursos genera HCL inválido.

import {
  to = aws_vpc.main
  id = "REPLACE_VPC_ID" # vpc-xxxxxxxx
}

import {
  to = aws_subnet.public
  id = "REPLACE_PUBLIC_SUBNET_ID" # subnet-xxxxxxxx
}

import {
  to = aws_subnet.private
  id = "REPLACE_PRIVATE_SUBNET_ID" # subnet-xxxxxxxx
}

import {
  to = aws_internet_gateway.igw
  id = "REPLACE_IGW_ID" # igw-xxxxxxxx
}

import {
  to = aws_eip.nat
  id = "REPLACE_EIP_ALLOCATION_ID" # eipalloc-xxxxxxxx
}

import {
  to = aws_nat_gateway.nat
  id = "REPLACE_NAT_GW_ID" # nat-xxxxxxxx
}

import {
  to = aws_route_table.public
  id = "REPLACE_PUBLIC_RT_ID" # rtb-xxxxxxxx
}

import {
  to = aws_route_table.private
  id = "REPLACE_PRIVATE_RT_ID" # rtb-xxxxxxxx
}

import {
  to = aws_route_table_association.public
  id = "REPLACE_PUBLIC_SUBNET_ID/REPLACE_PUBLIC_RT_ID" # formato: subnet-.../rtb-...
}

import {
  to = aws_route_table_association.private
  id = "REPLACE_PRIVATE_SUBNET_ID/REPLACE_PRIVATE_RT_ID"
}

import {
  to = aws_network_acl.public
  id = "REPLACE_PUBLIC_NACL_ID" # acl-xxxxxxxx
}

import {
  to = aws_network_acl.private
  id = "REPLACE_PRIVATE_NACL_ID" # acl-xxxxxxxx
}

import {
  to = aws_security_group.public
  id = "REPLACE_PUBLIC_SG_ID" # sg-xxxxxxxx
}

import {
  to = aws_security_group.private
  id = "REPLACE_PRIVATE_SG_ID" # sg-xxxxxxxx
}
