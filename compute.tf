# ─────────────────────────────────────────────────────────────────────────────
# COMPUTE — las máquinas se generan con IA (ejercicio "IaC con IA").
# ─────────────────────────────────────────────────────────────────────────────
# Las VMs ya NO se crean a mano por consola: se generan como código y se
# validan con shift-left ANTES del apply.
#
# 1) PROMPT INICIAL (a propósito INGENUO — así Checkov tiene algo que encontrar):
#
#      "Generá Terraform (AWS provider v5) para dos instancias EC2 en us-east-1:
#       una 'public' en la subred var.public_subnet_id y una 'private' en
#       var.private_subnet_id. Tipo t3.micro. key_name = var.key_name.
#       AMI = data.aws_ssm_parameter.al2023.value. Devolvé solo HCL."
#
#    Pegá el resultado acá abajo. NO hagas `terraform apply` todavía.
#
# 2) SHIFT-LEFT — corré:  checkov -d .
#    Casi seguro te marca (¡y está bien que lo haga!):
#      CKV_AWS_79       → IMDSv2 no obligatorio   (¿se acuerdan de Capital One? slide 10)
#      CKV_AWS_8 / _3   → volumen EBS sin cifrar
#      CKV_AWS_24 / 260 → 22/TCP abierto a 0.0.0.0/0
#      CKV_AWS_135      → EBS optimization, etc.
#
# 3) ARREGLÁ hasta que pase. La versión segura debería incluir, como mínimo:
#      metadata_options { http_tokens = "required" }      # IMDSv2 obligatorio
#      root_block_device { encrypted = true }             # volumen cifrado
#      SSH solo desde var.allowed_ssh_cidr (nunca 0.0.0.0/0)
#      associate_public_ip_address = false  en la privada
#
# 4) Lo que decidas SUPRIMIR, documentalo en checkov.yaml con su justificación.
#    "Una supresión sin justificar es una vulnerabilidad con papeleo."
#
# (vacío a propósito — esto lo completás vos con la IA)
