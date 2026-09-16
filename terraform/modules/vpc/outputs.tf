output "vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Subnets in the existing default VPC"
  value       = data.aws_subnets.default.ids
}
