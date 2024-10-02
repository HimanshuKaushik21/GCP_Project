# Create the VPC
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Public subnets
resource "google_compute_subnetwork" "public_subnet" {
  count = length(var.public_subnet_ip_ranges)

  name          = "${var.network_name}-public-subnet-${count.index + 1}"
  ip_cidr_range = var.public_subnet_ip_ranges[count.index]
  region        = var.subnet_regions[count.index]
  network       = google_compute_network.vpc_network.id
}

# Private subnets
resource "google_compute_subnetwork" "private_subnet" {
  count = length(var.private_subnet_ip_ranges)

  name          = "${var.network_name}-private-subnet-${count.index + 1}"
  ip_cidr_range = var.private_subnet_ip_ranges[count.index]
  region        = var.subnet_regions[count.index]
  network       = google_compute_network.vpc_network.id
}

# Create a default route to the internet for public subnets
resource "google_compute_router" "public_router" {
  name    = "${var.network_name}-public-router"
  region  = var.subnet_regions[0]
  network = google_compute_network.vpc_network.id
}

resource "google_compute_route" "public_internet_route" {
  count    = length(var.public_subnet_ip_ranges)

  name              = "${google_compute_subnetwork.public_subnet[count.index].name}-internet-route"
  network           = google_compute_network.vpc_network.id
  dest_range        = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority          = 1000
}

# Create a NAT gateway for private subnets if NAT is enabled
resource "google_compute_router" "nat_router" {
  count   = var.nat_enabled ? 1 : 0
  name    = "${var.network_name}-nat-router"
  region  = var.subnet_regions[0]
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat_gateway" {
  count                                   = var.nat_enabled ? 1 : 0
  name                                    = "${var.network_name}-nat"
  router                                  = google_compute_router.nat_router[0].name
  region                                  = google_compute_router.nat_router[0].region

  source_subnetwork_ip_ranges_to_nat      = "ALL_SUBNETWORKS_ALL_IP_RANGES"  # Use this to allow all private subnets
  nat_ip_allocate_option                   = "AUTO_ONLY"
  enable_dynamic_port_allocation           = true

  dynamic "subnetwork" {
    for_each = google_compute_subnetwork.private_subnet  # Ensure this resource is defined
    content {
      name                     = subnetwork.value.name  # Access the specific instance name
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]      # NAT IP ranges for this subnet
    }
  }
}



# Private subnets will have routes to the NAT gateway for internet access
resource "google_compute_route" "private_nat_route" {
  count    = var.nat_enabled ? length(var.private_subnet_ip_ranges) : 0

  name           = "${google_compute_subnetwork.private_subnet[count.index].name}-nat-route"
  network        = google_compute_network.vpc_network.id
  dest_range     = "0.0.0.0/0"
  next_hop_gateway = google_compute_router_nat.nat_gateway[0].name
  priority       = 1000
}
