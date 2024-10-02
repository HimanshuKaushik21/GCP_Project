output "network_name" {
  value = google_compute_network.vpc_network.name
}

output "public_subnets" {
  value = google_compute_subnetwork.public_subnet[*].name
}

output "private_subnets" {
  value = google_compute_subnetwork.private_subnet[*].name
}
