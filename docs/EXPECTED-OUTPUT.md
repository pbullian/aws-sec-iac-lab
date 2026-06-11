# Salida esperada (referencia)

Resultados reales del flujo completo, validados contra un AWS Academy Learner Lab.
Usalo para comparar lo que ves vos. Los IDs van a ser distintos; los **conteos y
mensajes clave** son lo que importa.

---

## 1. Importar la red (`fill-imports.sh` + `terraform`)

`bash fill-imports.sh` descubre tu red y escribe **`imports.tf`**:
```
VPC: vpc-0a90d4c3351a90149
  igw          igw-0336d15100b3fbc15
  nat          nat-092e4e7294d4d6550
  pub_subnet   subnet-07e5d719542f20f46
  ...
✓ imports.tf escrito.
```

`terraform plan` (antes de aplicar) — **lo importante: `0 to destroy`**:
```
Plan: 14 to import, 0 to add, 12 to change, 0 to destroy.
```
> Los 12 "change" son SOLO tags (el `default_tags` agrega Department/ManagedBy).
> Nada se recrea ni se destruye.

`terraform apply`:
```
Apply complete! Resources: 14 imported, 0 added, 12 changed, 0 destroyed.
```

`terraform plan` (de nuevo) — **el objetivo**:
```
No changes. Your infrastructure matches the configuration.
```

### Archivos / comandos para revisar
| Comando / archivo | Qué te muestra |
|---|---|
| `cat imports.tf` | Los 14 IDs que importaste (los escribió el helper). |
| `terraform state list` | Los 14 recursos ya bajo control de Terraform. |
| `terraform show` | Estado completo: config declarada + atributos reales en AWS. |
| `terraform plan` | Debe decir **No changes** = código y nube coinciden. |
| `ls /tmp/tfdata` | Dónde vive el provider (NO en `$HOME`, por el límite de 1 GB). |

`terraform state list` esperado:
```
aws_eip.nat
aws_internet_gateway.igw
aws_nat_gateway.nat
aws_network_acl.private
aws_network_acl.public
aws_route_table.private
aws_route_table.public
aws_route_table_association.private
aws_route_table_association.public
aws_security_group.private
aws_security_group.public
aws_subnet.private
aws_subnet.public
aws_vpc.main
```

---

## 2. Shift-left sobre las máquinas generadas (`trivy config .`)

Con el `compute.tf` **ingenuo** (sin endurecer), Trivy marca:
```
AWS-0028 (HIGH)     Instance does not require IMDS access to require a token.   (x2)
AWS-0131 (HIGH)     Root block device is not encrypted.                          (x2)
AWS-0107 (HIGH)     Security group rule allows unrestricted ingress (SSH 0.0.0.0/0)
AWS-0104 (CRITICAL) Security group rule allows unrestricted egress
```
> AWS-0028 (IMDSv2) es exactamente el vector de **Capital One** (slide de horror stories).
> Las de Security Group son de la red ("por ahora") — el lab te pide razonar sobre ellas.

Con el `compute.tf` **seguro** (IMDSv2 + disco cifrado) → 0 findings en las instancias.

---

## 3. Crear las máquinas (`terraform apply`)

```
aws_instance.public:  Creation complete  [id=i-0288103dcb815d3b5]
aws_instance.private: Creation complete  [id=i-00d1352f22de8fd32]
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

`terraform output` / verificación en AWS:
```
web-public   running   IMDSv2=required   root encrypted=True   PubIP=50.19.34.91
db-private   running   IMDSv2=required   root encrypted=True   PubIP=None        ← correcto
```

---

## 4. Limpieza (`terraform destroy`)

Como TODO está en el state (red importada + máquinas), un solo comando borra todo:
```
Destroy complete! Resources: 16 destroyed.
```
Verificá que no quede NAT GW ni EIP facturando:
```
aws ec2 describe-nat-gateways --filter Name=state,Values=available --query 'length(NatGateways)'  → 0
aws ec2 describe-addresses --query 'length(Addresses)'                                              → 0
```
