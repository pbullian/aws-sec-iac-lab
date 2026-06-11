variable "region" {
  description = "Región de AWS. En el AWS Academy Learner Lab usá us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Tag Project (ver Lab de Tagging, slide 33)."
  type        = string
  default     = "laboratory01"
}

variable "department" {
  description = "Tag Department: tu identificación de clase/grupo."
  type        = string
}

variable "key_name" {
  description = "Key pair que YA existe en el Learner Lab."
  type        = string
  default     = "vockey"
}

variable "allowed_ssh_cidr" {
  description = <<-EOT
    CIDR autorizado a conectarse por SSH (22/TCP).
    NO uses 0.0.0.0/0 — poné tu IP pública con /32 (principio de menor privilegio).
    Ej: "203.0.113.4/32". Sin default a propósito: te obliga a decidirlo.
  EOT
  type        = string

  validation {
    condition     = var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "0.0.0.0/0 deja SSH abierto a todo internet. Usá tu IP /32."
  }
}

# ── IDs de la red que creaste A MANO (para importar / referenciar) ───────────
# Los completás en terraform.tfvars después de anotarlos de la consola.
variable "vpc_id" {
  description = "ID de la VPC creada a mano."
  type        = string
  default     = ""
}

variable "public_subnet_id" {
  description = "ID de la subred pública creada a mano."
  type        = string
  default     = ""
}

variable "private_subnet_id" {
  description = "ID de la subred privada creada a mano."
  type        = string
  default     = ""
}
