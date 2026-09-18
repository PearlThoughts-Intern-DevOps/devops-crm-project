output "ec2_public_ip" { value = module.ec2.public_ip }
output "ecr_url" { value = module.ecr.repository_url }
output "s3_bucket" { value = module.s3.bucket_name }
