# aws-sec-iac-lab

Repositorio base para la sección **IaC + Shift-Left** del curso
**Seguridad en la Nube — Maestría en Seguridad Informática (UBA)**.

La idea del laboratorio:

1. Construís la **red a mano** en la consola (VPC, subredes, route tables, NACLs,
   security groups) — para entender las primitivas.
2. La **importás** a Terraform (`terraform import`) — lo hecho a mano pasa a ser código.
3. Generás las **máquinas con IA** (Terraform), las **validás con shift-left**
   (Trivy / Checkov) y recién ahí hacés `apply`. Las VMs quedan **100% como código**.

> Filosofía: **"Generá rápido con IA, validá siempre con shift-left."**
> Una supresión de un control sin justificación es una vulnerabilidad con papeleo.

> ✅ Flujo validado end-to-end contra un AWS Academy Learner Lab real
> (import de 14 recursos → `plan` = *No changes* → 2 EC2 con IMDSv2 + disco cifrado → `destroy`).

---

## Entorno: AWS CloudShell (nada que instalar en tu máquina)

Todo corre **en AWS**. No necesitás instalar nada localmente.

1. Entrá a la consola del Learner Lab → ícono **CloudShell** (barra superior).
   *(CloudShell ya usa tus credenciales del lab — no copiás ni pegás keys.)*
2. Una sola vez, instalá las herramientas en tu `$HOME` persistente:
   ```bash
   git clone https://github.com/pbullian/aws-sec-iac-lab.git
   cd aws-sec-iac-lab
   bash bootstrap.sh        # Terraform + Trivy → ~/.local/bin  (~90 s)
   exec bash                # recargar PATH
   ```

> ¿CloudShell deshabilitado en tu sección? Hay un `.devcontainer` (Codespaces o
> Docker local) como alternativa — ahí sí pegás las 3 credenciales del lab una vez.

---

## Pre-requisitos (los instala `bootstrap.sh`)

- **Terraform ≥ 1.5** *o* **OpenTofu ≥ 1.6** (para los bloques `import {}`).
- **Trivy** — scanner shift-left local (binario único, rápido).
- *(CI usa **Checkov** además — corre solo en GitHub Actions, no en tu máquina.)*

---

## Flujo del laboratorio

### Lab A — El repositorio base
`bootstrap.sh` + `terraform init`. Completá `terraform.tfvars`
(`department`, `allowed_ssh_cidr`). Mirá que `network.tf` ya trae los bloques y
`compute.tf` está vacío a propósito.

### Lab B — Importá tu red a Terraform
1. Anotá de la consola los IDs de lo que creaste a mano.
2. Pegalos en `imports.tf` (reemplazá los `REPLACE_*`).
3. Ajustá `network.tf` si tu red difiere (CIDR, AZ, reglas).
4. Importá y converge:
   ```bash
   terraform plan      # "14 to import, N to change"  (N = sólo tags → OK)
   terraform apply      # importa + converge tags; NADA se recrea
   terraform plan       # → "No changes." ✅
   ```

> ⚠️ **No uses `terraform plan -generate-config-out`** para esto: genera HCL
> inválido (atributos en cero/conflictivos) para VPC/subred/etc. Por eso
> `network.tf` ya viene escrito. El camino confiable es config + `import`.

### Lab C — Máquinas con IA + shift-left
1. Generá `compute.tf` con tu asistente de IA (prompt inicial dentro del archivo).
2. **Escaneá ANTES de aplicar:**
   ```bash
   trivy config .
   ```
   Va a marcar IMDSv2 (AWS-0028), disco sin cifrar (AWS-0131), SSH 0.0.0.0/0. **Está bien.**
3. Arreglá hasta que pase. Documentá supresiones justificadas.
4. Recién ahora:
   ```bash
   terraform plan
   terraform apply       # 2 EC2, como código y ya validadas
   ```

---

## Estructura

| Archivo | Qué es |
|---|---|
| `bootstrap.sh` | Instala Terraform + Trivy en CloudShell (`~/.local/bin`). |
| `versions.tf` / `providers.tf` | Versiones + provider AWS con `default_tags`. |
| `variables.tf` | Variables (incluye `allowed_ssh_cidr` con validación anti-`0.0.0.0/0`). |
| `data.tf` | AMI de Amazon Linux 2023 vía SSM (sin hardcodear IDs). |
| `network.tf` | Bloques de la red **ya escritos** — el target del import *(Lab B)*. |
| `imports.tf` | Bloques `import {}` — pegás tus IDs *(Lab B)*. |
| `compute.tf` | Las VMs — **las generás con IA** *(Lab C, arranca vacío)*. |
| `outputs.tf` | IPs y comando SSH *(descomentar tras crear compute)*. |
| `backend.tf` | Estado remoto S3 *(opcional; por defecto state local)*. |
| `checkov.yaml` / `.pre-commit-config.yaml` / `.github/workflows/ci.yml` | Shift-left adicional. |

---

## Limpieza

Como toda la red queda importada a Terraform, **un solo comando borra todo**
(VMs + red + NAT GW + EIP) — clave para no dejar el NAT GW facturando:
```bash
terraform destroy
```

---

*Material docente. Sin secretos: `*.tfstate`, `*.pem` y `terraform.tfvars` están gitignoreados.*
