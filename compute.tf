# ─────────────────────────────────────────────────────────────────────────────
# COMPUTE — las máquinas se generan con IA (ejercicio "IaC con IA").
# ─────────────────────────────────────────────────────────────────────────────
# Las VMs ya NO se crean a mano por consola: se generan como código y se
# validan con shift-left ANTES del apply.
#
# 1) PROMPT INICIAL (a propósito INGENUO — así el scanner tiene algo que marcar):
#
#      "Generá Terraform para dos instancias EC2 en us-east-1: una 'public' en
#       la subred aws_subnet.public y una 'private' en aws_subnet.private,
#       tipo t3.micro, key_name = var.key_name,
#       ami = data.aws_ssm_parameter.al2023.value. Devolvé solo HCL."
#
#    Pegá el resultado acá abajo. NO hagas `terraform apply` todavía.
#
# 2) SHIFT-LEFT — escaneá ANTES de aplicar:
#      trivy config .            # en CloudShell (rápido, binario único)
#    Casi seguro te marca (¡y está bien!):
#      AWS-0028 (HIGH)  → IMDSv2 no obligatorio   (¿se acuerdan de Capital One? slide 10)
#      AWS-0131 (HIGH)  → volumen root sin cifrar
#      AWS-0107/0104    → SG 22 abierto a 0.0.0.0/0  (lo de la red, "por ahora")
#
# 3) ARREGLÁ hasta que pase. La versión segura incluye, como mínimo:
#      metadata_options { http_tokens = "required" }      # IMDSv2 obligatorio
#      root_block_device { encrypted = true }             # volumen cifrado
#      associate_public_ip_address = false  en la privada
#
# 4) Recién con el scan limpio:  terraform plan → terraform apply.
#    (validado end-to-end: 2 EC2 t3.micro, IMDSv2 required, root cifrado)
#
# (vacío a propósito — esto lo completás vos con la IA)
