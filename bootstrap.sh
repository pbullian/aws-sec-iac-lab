#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# bootstrap.sh — preparar el entorno en AWS CloudShell (~90 s, una sola vez)
# ─────────────────────────────────────────────────────────────────────────────
# CloudShell ya viene autenticado con las credenciales del Learner Lab
# (no hay que copiar/pegar keys) y tiene 1 GB de HOME persistente.
# `yum`/`dnf` NO persisten, pero ~/.local/bin SÍ → instalamos ahí.
#
# Uso:  bash bootstrap.sh   (o:  source bootstrap.sh  para tener el PATH activo ya)
set -euo pipefail

TF_VERSION="1.9.8"      # >=1.5 para import {} (bumpeá si querés)
TRIVY_VERSION="0.71.0"  # scanner shift-left (binario único)

mkdir -p "$HOME/.local/bin"

if ! "$HOME/.local/bin/terraform" version >/dev/null 2>&1; then
  echo "→ Instalando Terraform ${TF_VERSION}..."
  curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -o /tmp/tf.zip
  unzip -o /tmp/tf.zip -d "$HOME/.local/bin" >/dev/null
  rm -f /tmp/tf.zip
fi

if ! "$HOME/.local/bin/trivy" --version >/dev/null 2>&1; then
  echo "→ Instalando Trivy ${TRIVY_VERSION}..."
  curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" -o /tmp/trivy.tgz
  tar -xzf /tmp/trivy.tgz -C "$HOME/.local/bin" trivy
  rm -f /tmp/trivy.tgz
fi

# Persistir el PATH para las próximas sesiones de CloudShell
if ! grep -q 'HOME/.local/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "✅ Listo:"
terraform version | head -1
trivy --version | head -1
echo ""
if command -v aws >/dev/null 2>&1; then
  echo "Credenciales (ya las da CloudShell, sin copiar nada):"
  aws sts get-caller-identity --query 'Arn' --output text || true
else
  echo "Credenciales: en CloudShell ya vienen (verificá con: aws sts get-caller-identity)."
fi
echo ""
echo "Siguiente:  terraform init"
