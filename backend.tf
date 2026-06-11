# ─────────────────────────────────────────────────────────────────────────────
# ESTADO REMOTO (producción) — opcional en el laboratorio.
# ─────────────────────────────────────────────────────────────────────────────
# En el Learner Lab arrancamos con estado LOCAL (archivo terraform.tfstate,
# gitignoreado). Es lo más simple para un solo alumno.
#
# En el mundo real el state va remoto, cifrado y con lock para evitar que dos
# personas apliquen a la vez. Para activarlo: creá un bucket S3 (el Learner Lab
# permite S3 — lo usaste en el lab de Flow Logs) y descomentá:
#
# terraform {
#   backend "s3" {
#     bucket         = "TU-BUCKET-tfstate"
#     key            = "aws-sec-iac-lab/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"   # opcional: lock (puede estar restringido)
#   }
# }
