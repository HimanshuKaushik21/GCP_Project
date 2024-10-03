# Create the VPC
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Public subnets
resource "google_compute_subnetwork" "public_subnet" {
  count = length(var.public_subnet_ip_ranges)

  name          = "${var.network_name}-public-subnet-${count.index}"
  ip_cidr_range = var.public_subnet_ip_ranges[count.index]
  region        = var.subnet_regions[0]
  network       = google_compute_network.vpc_network.id
}

# Private subnets
resource "google_compute_subnetwork" "private_subnet" {
  count = length(var.private_subnet_ip_ranges)

  name          = "${var.network_name}-private-subnet-${count.index}"
  ip_cidr_range = var.private_subnet_ip_ranges[count.index]
  region        = var.subnet_regions[0]
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_route" "public_internet_route" {
  name              = "${google_compute_network.vpc_network.name}-ig-route"
  network           = google_compute_network.vpc_network.id
  dest_range        = "0.0.0.0/0"
  next_hop_gateway  = "default-internet-gateway"
  priority          = 1000
}


#################### Nat routes#####################
resource "google_compute_router" "nat_router" {
  name    = "${var.network_name}-nat-router"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat_gateway" {
  count  = length(var.private_subnet_ip_ranges)

  name   = "${var.network_name}-ng"
  router = google_compute_router.nat_router.name
  nat_ip_allocate_option = "AUTO_ONLY"  # Automatically allocate external IPs
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name = google_compute_subnetwork.private_subnet[count.index].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"  # Change to "ALL" for detailed logs
  }
}

