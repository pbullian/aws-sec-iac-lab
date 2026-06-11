#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build-network.sh — levanta la red del lab vía AWS CLI.
# ─────────────────────────────────────────────────────────────────────────────
# SOLO para TESTEAR/DEMO el flujo IaC sin reclickear la consola.
# En clase, los alumnos construyen esta red A MANO (slides 25-44). Este script
# crea exactamente lo mismo para que puedas probar import → apply → destroy rápido.
#
# Uso (en CloudShell, ya autenticado):  bash scripts/build-network.sh
# Tiempo: ~2 min (espera al NAT Gateway).
set -euo pipefail
R="${AWS_DEFAULT_REGION:-us-east-1}"
save(){ printf '  %-14s %s\n' "$1" "$2"; }

echo "== VPC =="
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=lab-vpc},{Key=Project,Value=laboratory01}]" \
  --query 'Vpc.VpcId' --output text); save VPC_ID "$VPC_ID"
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-support '{"Value":true}'
aws ec2 modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames '{"Value":true}'

echo "== Subnets =="
PUB_SUBNET=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block 10.0.1.0/24 --availability-zone ${R}a \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=lab-public},{Key=Project,Value=laboratory01}]" \
  --query 'Subnet.SubnetId' --output text); save PUB_SUBNET "$PUB_SUBNET"
PRIV_SUBNET=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block 10.0.2.0/24 --availability-zone ${R}a \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=lab-private},{Key=Project,Value=laboratory01}]" \
  --query 'Subnet.SubnetId' --output text); save PRIV_SUBNET "$PRIV_SUBNET"

echo "== Internet Gateway =="
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=lab-igw}]" \
  --query 'InternetGateway.InternetGatewayId' --output text); save IGW_ID "$IGW_ID"
aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"

echo "== EIP + NAT Gateway (espera ~1-2 min) =="
EIP_ALLOC=$(aws ec2 allocate-address --domain vpc \
  --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=lab-nat-eip}]" \
  --query 'AllocationId' --output text); save EIP_ALLOC "$EIP_ALLOC"
NAT_ID=$(aws ec2 create-nat-gateway --subnet-id "$PUB_SUBNET" --allocation-id "$EIP_ALLOC" \
  --tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=lab-nat}]" \
  --query 'NatGateway.NatGatewayId' --output text); save NAT_ID "$NAT_ID"
aws ec2 wait nat-gateway-available --nat-gateway-ids "$NAT_ID"; echo "  NAT listo."

echo "== Route tables =="
PUB_RT=$(aws ec2 create-route-table --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=lab-public-rt}]" \
  --query 'RouteTable.RouteTableId' --output text); save PUB_RT "$PUB_RT"
aws ec2 create-route --route-table-id "$PUB_RT" --destination-cidr-block 0.0.0.0/0 --gateway-id "$IGW_ID" >/dev/null
aws ec2 associate-route-table --route-table-id "$PUB_RT" --subnet-id "$PUB_SUBNET" >/dev/null
PRIV_RT=$(aws ec2 create-route-table --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=lab-private-rt}]" \
  --query 'RouteTable.RouteTableId' --output text); save PRIV_RT "$PRIV_RT"
aws ec2 create-route --route-table-id "$PRIV_RT" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "$NAT_ID" >/dev/null
aws ec2 associate-route-table --route-table-id "$PRIV_RT" --subnet-id "$PRIV_SUBNET" >/dev/null

echo "== NACLs =="
PUB_NACL=$(aws ec2 create-network-acl --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=network-acl,Tags=[{Key=Name,Value=lab-public-nacl}]" \
  --query 'NetworkAcl.NetworkAclId' --output text); save PUB_NACL "$PUB_NACL"
aws ec2 create-network-acl-entry --network-acl-id "$PUB_NACL" --rule-number 100 --protocol tcp --port-range From=22,To=22 --cidr-block 0.0.0.0/0 --rule-action allow --ingress
aws ec2 create-network-acl-entry --network-acl-id "$PUB_NACL" --rule-number 110 --protocol tcp --port-range From=1024,To=65535 --cidr-block 0.0.0.0/0 --rule-action allow --ingress
aws ec2 create-network-acl-entry --network-acl-id "$PUB_NACL" --rule-number 100 --protocol -1 --cidr-block 0.0.0.0/0 --rule-action allow --egress
A=$(aws ec2 describe-network-acls --filters Name=association.subnet-id,Values=$PUB_SUBNET --query "NetworkAcls[0].Associations[?SubnetId=='$PUB_SUBNET'].NetworkAclAssociationId" --output text)
aws ec2 replace-network-acl-association --association-id "$A" --network-acl-id "$PUB_NACL" >/dev/null
PRIV_NACL=$(aws ec2 create-network-acl --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=network-acl,Tags=[{Key=Name,Value=lab-private-nacl}]" \
  --query 'NetworkAcl.NetworkAclId' --output text); save PRIV_NACL "$PRIV_NACL"
aws ec2 create-network-acl-entry --network-acl-id "$PRIV_NACL" --rule-number 100 --protocol tcp --port-range From=22,To=22 --cidr-block 10.0.1.0/24 --rule-action allow --ingress
aws ec2 create-network-acl-entry --network-acl-id "$PRIV_NACL" --rule-number 110 --protocol tcp --port-range From=1024,To=65535 --cidr-block 0.0.0.0/0 --rule-action allow --ingress
aws ec2 create-network-acl-entry --network-acl-id "$PRIV_NACL" --rule-number 100 --protocol -1 --cidr-block 0.0.0.0/0 --rule-action allow --egress
A=$(aws ec2 describe-network-acls --filters Name=association.subnet-id,Values=$PRIV_SUBNET --query "NetworkAcls[0].Associations[?SubnetId=='$PRIV_SUBNET'].NetworkAclAssociationId" --output text)
aws ec2 replace-network-acl-association --association-id "$A" --network-acl-id "$PRIV_NACL" >/dev/null

echo "== Security Groups =="
SG_PUBLIC=$(aws ec2 create-security-group --group-name PUBLIC-ACCESS --description "Public access SG" --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=PUBLIC-ACCESS}]" \
  --query 'GroupId' --output text); save SG_PUBLIC "$SG_PUBLIC"
aws ec2 authorize-security-group-ingress --group-id "$SG_PUBLIC" --protocol tcp --port 22 --cidr 0.0.0.0/0 >/dev/null
SG_PRIVATE=$(aws ec2 create-security-group --group-name PRIVATE-ACCESS --description "Private access SG" --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=PRIVATE-ACCESS}]" \
  --query 'GroupId' --output text); save SG_PRIVATE "$SG_PRIVATE"
aws ec2 authorize-security-group-ingress --group-id "$SG_PRIVATE" --protocol tcp --port 22 --cidr 10.0.1.0/24 >/dev/null

echo ""
echo "✓ Red lista. Ahora:  bash fill-imports.sh  &&  terraform init && terraform apply"
