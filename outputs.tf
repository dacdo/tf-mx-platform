# Output variable definitions

output "aws_vpc_endpoint_id" {
  description = "aws_vpc_endpoint_id"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.dd_vpc.id
}

output "public_subnet_id" {
  description = "public subnet id"
  value       = aws_subnet.public-subnet.id
}

output "private_subnet_id" {
  description = "private subnet id"
  value       = aws_subnet.private-subnet.id
}


output "aws_iam_instance_profile" {
  description = "aws_iam_instance_profile"
  value       = aws_iam_instance_profile.test_profile.id
}
