resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = local.common_tags
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  count           = length(module.vpc.private_route_table_ids)
  route_table_id  = module.vpc.private_route_table_ids[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}