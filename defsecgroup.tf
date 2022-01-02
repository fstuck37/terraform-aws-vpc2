resource "aws_default_security_group" "default" {
  for_each = { for sg in [var.region] : sg => sg
  if var.override_default_security_group }
  vpc_id = aws_vpc.main_vpc.id
}