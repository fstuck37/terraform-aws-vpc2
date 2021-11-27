##################################################
# File: natgw.tf                                 #
# Created Date: 03192019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates an NAT Gateway            #
#                                                #
# Change History:                                #
# 03192019: Initial File                         #
# 03282019: Changed count to same as EIP         #
#                                                #
##################################################

resource "aws_nat_gateway" "natgw" {
  count = contains(keys(var.subnets), "pub")  && !(var.deploy_natgateways == false) ? local.num-availbility-zones : 0
  allocation_id  = aws_eip.eip.*.id[count.index]
  subnet_id = local.pub-subnet-ids[count.index]
}


/* NOTE: Hard coded to ngw layer */
resource "aws_nat_gateway" "natgw" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "ngw" }
  allocation_id  = aws_eip.eip[each.value.az].id
  subnet_id      = aws_subnet.subnets[each.value.name].id
  tags = {
    Name = each.value.name
  }
}
