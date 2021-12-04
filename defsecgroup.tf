resource "aws_default_security_group" "default" {
  for_each = {for sg in [var.region] : sg => sg
              if var.disable_default_security_group_override }
  vpc_id     = aws_vpc.main_vpc.id
}


