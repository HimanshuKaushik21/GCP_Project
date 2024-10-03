variable "project_id" {
  description = "The project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The region for the resources"
  type        = string
  # default     = "us-central1"
}

variable "network_name" {
  description = "The name of the VPC"
  type        = string
}

variable "public_subnet_ip_ranges" {
  description = "The list of CIDR ranges for public subnets"
  type        = list(string)
}

variable "private_subnet_ip_ranges" {
  description = "The list of CIDR ranges for private subnets"
  type        = list(string)
}

variable "subnet_regions" {
  description = "The regions where subnets will be created"
  type        = list(string)
}

variable "nat_enabled" {
  description = "Enable Cloud NAT for private subnets"
  type        = bool
  default     = true
}
