locals {
  vpcs = [
    { 
      vpc_cidr      = "172.24.0.0/16",
      subnet_a_cidr = "172.24.10.0/24",
      subnet_b_cidr = "172.24.20.0/24",
      subnet_c_cidr = "172.24.30.0/24",
      name = "${var.environment}-vpc"
    },
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
  count             = length(aws_vpc.vpc)
  vpc_id            = aws_vpc.vpc[count.index].id
  cidr_block        = local.vpcs[count.index].subnet_a_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name        = "${local.vpcs[count.index].name}-a-subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "subnet_b" {
  count = length(aws_vpc.vpc)

  vpc_id            = aws_vpc.vpc[count.index].id
  cidr_block        = local.vpcs[count.index].subnet_b_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name        = "${local.vpcs[count.index].name}-b-subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "subnet_c" {
  count             = length(aws_vpc.vpc)
  vpc_id            = aws_vpc.vpc[count.index].id
  cidr_block        = local.vpcs[count.index].subnet_c_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name        = "${local.vpcs[count.index].name}-c-subnet"
    Environment = var.environment
  }
}

output "aws_vpc_ids" {
  value = aws_vpc.vpc[*].id
}

output "aws_vpc_subnet_a" {
  value = aws_subnet.subnet_a[*].id
}

output "aws_vpc_subnet_b" {
  value = aws_subnet.subnet_b[*].id
}

output "aws_vpc_subnet_c" {
  value = aws_subnet.subnet_c[*].id
}
