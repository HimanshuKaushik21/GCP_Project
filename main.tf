provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("abstract-brand-435818-g6-b30930c2ad7a.json")
}

module "vpc" {
  source                   = "./modules/vpc"
  project_id               = var.project_id
  network_name             = var.network_name
  public_subnet_ip_ranges  = var.public_subnet_ip_ranges
  private_subnet_ip_ranges = var.private_subnet_ip_ranges
  subnet_regions           = var.subnet_regions
  nat_enabled              = var.nat_enabled
}


module "gke" {
  source = "./modules/gke"
}