provider "aws" {
  region = var.region

  # Etiquetas aplicadas a TODOS los recursos creados por Terraform.
  # Conecta con el Lab de Tagging (slides 31-33): la política de tags ahora
  # se aplica sola, no a mano recurso por recurso.
  default_tags {
    tags = {
      Project    = var.project
      Department = var.department
      ManagedBy  = "terraform"
    }
  }
}
