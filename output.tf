output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = module.vpc.network_name
}

output "public_subnets" {
  description = "The public subnets created in the VPC"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "The private subnets created in the VPC"
  value       = module.vpc.private_subnets
}
