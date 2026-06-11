# aws-sec-iac-lab

Repositorio base para la sección **IaC + Shift-Left** del curso
**Seguridad en la Nube — Maestría en Seguridad Informática (UBA)**.

La idea del laboratorio:

1. Construís la **red a mano** en la consola (VPC, subredes, route tables, NACLs,
   security groups) — para entender las primitivas.
2. La **importás** a Terraform (`terraform import`) — lo hecho a mano pasa a ser código.
3. Generás las **máquinas con IA** (Terraform), las **validás con shift-left**
   (Checkov) y recién ahí hacés `apply`. Las VMs quedan **100% como código**.

> Filosofía: **"Generá rápido con IA, validá siempre con shift-left."**
> Una supresión de un control sin justificación es una vulnerabilidad con papeleo.

---

## Pre-requisitos

- **AWS Academy Learner Lab** activo (credenciales temporales desde *AWS Details*).
- **Terraform ≥ 1.5** *o* **OpenTofu ≥ 1.6** (`terraform` / `tofu`).
- **Python 3** + **Checkov**: `pip install checkov`
- (Opcional) **pre-commit**: `pip install pre-commit && pre-commit install`

### Cargar credenciales del Learner Lab

Las credenciales del Learner Lab son **temporales** (caducan cada pocas horas).
Copialas de *AWS Details → AWS CLI* a `~/.aws/credentials` o exportalas:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
export AWS_DEFAULT_REGION=us-east-1
```

Si Terraform empieza a dar errores de auth, **re-exportá** — seguramente caducaron.

---

## Flujo del laboratorio

### Lab A — El repositorio base
```bash
git clone https://github.com/pbullian/aws-sec-iac-lab.git
cd aws-sec-iac-lab
cp terraform.tfvars.example terraform.tfvars   # completá department y allowed_ssh_cidr
terraform init
```
Recorré la estructura (abajo) para ver qué hay y qué falta.

### Lab B — Importá tu red a Terraform
1. Anotá de la consola los IDs de lo que creaste a mano y completalos en `terraform.tfvars`.
2. Descomentá los bloques `import {}` en `imports.tf`.
3. Generá el HCL:
   ```bash
   terraform plan -generate-config-out=network_generated.tf
   ```
4. Revisá lo generado, movelo a `network.tf`, borrá `network_generated.tf`.
5. **Objetivo:** `terraform plan` → **`No changes`**. Tu red hecha a mano ya es código.

### Lab C — Máquinas con IA + shift-left
1. Generá `compute.tf` con tu asistente de IA (prompt inicial sugerido dentro del archivo).
2. **Escaneá ANTES de aplicar:**
   ```bash
   checkov -d .
   ```
   Va a marcar cosas (IMDSv2, EBS sin cifrar, SSH 0.0.0.0/0…). **Está bien que lo haga.**
3. Arreglá hasta que pase. Documentá supresiones en `checkov.yaml`.
4. Recién ahora:
   ```bash
   terraform plan      # revisá el diff
   terraform apply      # las VMs quedan creadas, como código y ya validadas
   ```

---

## Estructura

| Archivo | Qué es |
|---|---|
| `versions.tf` | Versión de Terraform/OpenTofu y del provider AWS. |
| `providers.tf` | Provider AWS + `default_tags` (aplica la política de tags sola). |
| `variables.tf` | Variables (incluye `allowed_ssh_cidr` con validación anti-`0.0.0.0/0`). |
| `data.tf` | AMI de Amazon Linux 2023 vía SSM (sin hardcodear IDs). |
| `imports.tf` | Bloques `import {}` para adoptar la red hecha a mano *(Lab B)*. |
| `network.tf` | Recursos de red importados *(arranca vacío)*. |
| `compute.tf` | Las VMs — **las generás con IA** *(Lab C, arranca vacío)*. |
| `outputs.tf` | IPs y comando SSH *(descomentar tras crear compute)*. |
| `backend.tf` | Estado remoto S3 *(opcional; por defecto state local)*. |
| `checkov.yaml` | Config de shift-left + supresiones documentadas. |
| `.pre-commit-config.yaml` | Hooks: `fmt`, `validate`, `checkov` en cada commit. |
| `.github/workflows/ci.yml` | Gate de CI: bloquea el merge si Checkov falla. |

---

## Limpieza

Al terminar (¡y siempre antes de cerrar el lab por un tiempo largo!):
```bash
terraform destroy
```
Recordá además **eliminar el NAT GW** si lo creaste a mano (ver slide de NOTAS del curso).

---

*Material docente. Sin secretos: `*.tfstate`, `*.pem` y `terraform.tfvars` están gitignoreados.*
