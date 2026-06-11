# Terraform >= 1.5 → necesario para los bloques `import {}` y
# `terraform plan -generate-config-out` (generación de HCL).
# Compatible con OpenTofu >= 1.6 (`tofu` en vez de `terraform`).
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
