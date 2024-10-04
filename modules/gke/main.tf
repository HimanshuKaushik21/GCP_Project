resource "google_container_cluster" "primary" {
  name               = "my-gke-cluster"
  location           = "us-east1"  # Choose your desired zone
  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"  # Choose your desired machine type

    # Optional: Set up the node pool configuration
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  # Optional: Enable network policy
  network_policy {
    enabled = true
  }
}

output "kube_config" {
  value = google_container_cluster.primary.endpoint
}

# Registy

resource "google_artifact_registry_repository" "default" {
  provider = google
  repository_id = "docker-repo"  # Name of your repository
  format      = "DOCKER"                # Choose the format (DOCKER, MAVEN, NPM, etc.)
  location    = "us-east1"           # Choose the location
  description = "My Artifact Registry"   # Optional description
}
