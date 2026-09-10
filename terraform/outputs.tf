output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
  value = data.aws_subnet.selected.id
}

output "ec2_instance_id" {
  value = aws_instance.twenty.id
}

output "ec2_public_ip" {
  value = aws_instance.twenty.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.twenty.public_dns
}

output "s3_bucket_name" {
  value = aws_s3_bucket.twenty_storage.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.twenty_storage.arn
}
