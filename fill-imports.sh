#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# fill-imports.sh — descubre tu red en AWS y escribe imports.tf por vos.
# ─────────────────────────────────────────────────────────────────────────────
# Así no copiás 14 IDs a mano. Corré esto en CloudShell, dentro del repo,
# DESPUÉS de haber creado la red a mano.
#
#   bash fill-imports.sh [VPC_ID]
#
# Si no pasás VPC_ID, usa la única VPC NO-default de la cuenta.
# Clasifica subredes en pública/privada según su ruta 0.0.0.0/0 (IGW vs NAT).
set -euo pipefail

VPC="${1:-}"
if [ -z "$VPC" ]; then
  VPC=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=false \
        --query 'Vpcs[0].VpcId' --output text)
fi
[ -z "$VPC" ] || [ "$VPC" = "None" ] && { echo "✗ No encontré una VPC no-default. Pasá el VPC_ID: bash fill-imports.sh vpc-xxxx"; exit 1; }
echo "VPC: $VPC"

igw=$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPC \
      --query 'InternetGateways[0].InternetGatewayId' --output text)
nat=$(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$VPC Name=state,Values=available \
      --query 'NatGateways[0].NatGatewayId' --output text)
eip=$(aws ec2 describe-nat-gateways --nat-gateway-ids "$nat" \
      --query 'NatGateways[0].NatGatewayAddresses[0].AllocationId' --output text)

# Route tables: pública = la que rutea a IGW; privada = la que rutea al NAT
pub_rt=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC \
         --query "RouteTables[?Routes[?GatewayId=='$igw']].RouteTableId | [0]" --output text)
priv_rt=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC \
          --query "RouteTables[?Routes[?NatGatewayId=='$nat']].RouteTableId | [0]" --output text)
# Subred asociada a cada route table
pub_subnet=$(aws ec2 describe-route-tables --route-table-ids "$pub_rt" \
             --query 'RouteTables[0].Associations[?SubnetId!=null].SubnetId | [0]' --output text)
priv_subnet=$(aws ec2 describe-route-tables --route-table-ids "$priv_rt" \
              --query 'RouteTables[0].Associations[?SubnetId!=null].SubnetId | [0]' --output text)

# NACLs no-default, por subred asociada
pub_nacl=$(aws ec2 describe-network-acls --filters Name=vpc-id,Values=$VPC Name=default,Values=false \
           --query "NetworkAcls[?Associations[?SubnetId=='$pub_subnet']].NetworkAclId | [0]" --output text)
priv_nacl=$(aws ec2 describe-network-acls --filters Name=vpc-id,Values=$VPC Name=default,Values=false \
            --query "NetworkAcls[?Associations[?SubnetId=='$priv_subnet']].NetworkAclId | [0]" --output text)

# Security Groups por nombre
pub_sg=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC Name=group-name,Values=PUBLIC-ACCESS \
         --query 'SecurityGroups[0].GroupId' --output text)
priv_sg=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC Name=group-name,Values=PRIVATE-ACCESS \
          --query 'SecurityGroups[0].GroupId' --output text)

for v in VPC igw nat eip pub_rt priv_rt pub_subnet priv_subnet pub_nacl priv_nacl pub_sg priv_sg; do
  val="${!v}"
  [ -z "$val" ] || [ "$val" = "None" ] && { echo "✗ No pude descubrir '$v' — ¿lo creaste? ¿está tagueado?"; exit 1; }
  printf '  %-12s %s\n' "$v" "$val"
done

emit(){ printf 'import {\n  to = %s\n  id = "%s"\n}\n\n' "$1" "$2"; }
{
  echo "# Generado por fill-imports.sh — no editar a mano."
  echo ""
  emit aws_vpc.main                       "$VPC"
  emit aws_subnet.public                  "$pub_subnet"
  emit aws_subnet.private                 "$priv_subnet"
  emit aws_internet_gateway.igw           "$igw"
  emit aws_eip.nat                        "$eip"
  emit aws_nat_gateway.nat                "$nat"
  emit aws_route_table.public             "$pub_rt"
  emit aws_route_table.private            "$priv_rt"
  emit aws_route_table_association.public  "$pub_subnet/$pub_rt"
  emit aws_route_table_association.private "$priv_subnet/$priv_rt"
  emit aws_network_acl.public             "$pub_nacl"
  emit aws_network_acl.private            "$priv_nacl"
  emit aws_security_group.public          "$pub_sg"
  emit aws_security_group.private         "$priv_sg"
} > imports.tf
terraform fmt imports.tf >/dev/null 2>&1 || true
echo "✓ imports.tf escrito. Ahora: terraform init && terraform plan && terraform apply"
