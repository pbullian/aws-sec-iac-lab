# ─────────────────────────────────────────────────────────────────────────────
# RED — los recursos que importaste viven acá.
# ─────────────────────────────────────────────────────────────────────────────
# Este archivo arranca vacío A PROPÓSITO. Se llena en el Lab de import:
#
#   Opción A (recomendada): pegá acá lo que generó
#       terraform plan -generate-config-out=network_generated.tf
#     y ajustá nombres/variables.
#
#   Opción B (a mano): escribí los resources vos mismo hasta que
#       terraform plan  dé  "No changes".
#
# Tip: la red NO se recrea — `import` solo la trae al state. Si `plan` propone
# crear o destruir algo, tu HCL todavía no coincide con la realidad: corregilo.
