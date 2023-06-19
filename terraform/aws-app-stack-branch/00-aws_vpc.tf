locals {
  vpcs = [
    { vpc_cidr = "10.125.0.0/16", subnet_a_cidr = "10.125.10.0/24", name = "${var.environment}-vpc" },
  ]
}

resource "aws_vpc" "vpc" {
  count = length(local.vpcs)

  cidr_block = local.vpcs[count.index].vpc_cidr
  tags = {
    Name = local.vpcs[count.index].name
    Environment = var.environment
  }
}

resource "aws_subnet" "subnet_a" {
  count = length(aws_vpc.vpc)

  vpc_id     = aws_vpc.vpc[count.index].id
  cidr_block = local.vpcs[count.index].subnet_a_cidr
  tags = {
    Name = "${local.vpcs[count.index].name}-subnet"
    Environment = var.environment
  }
}

output "aws_vpc_ids" {
  value = aws_vpc.vpc[*].id
}

output "aws_vpc_subnet_a" {
  value = aws_subnet.subnet_a[*].id
}