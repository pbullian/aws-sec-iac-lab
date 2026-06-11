# AMI más reciente de Amazon Linux 2023 vía SSM Public Parameter.
# Nunca hardcodees un AMI ID: cambian por región y con cada release.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Uso en compute.tf:  ami = data.aws_ssm_parameter.al2023.value
