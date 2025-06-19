resource "google_container_cluster" "primary" {
  name     = var.gke_options.cluster_name
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false

  network    = data.google_compute_network.default.name
  subnetwork = google_compute_subnetwork.gke_subnetwork.name

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.gke_subnetwork.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke_subnetwork.secondary_ip_range[1].range_name
  }
  private_cluster_config {
    enable_private_endpoint = var.gke_options.enable_private_endpoint
    enable_private_nodes    = var.gke_options.enable_private_nodes
    master_ipv4_cidr_block  = var.gke_options.master_ipv4_cidr_block
    master_global_access_config {
      enabled = true
    }
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.network_options.gke_node_cidr
    }
    cidr_blocks {
      cidr_block = data.google_compute_subnetwork.default.ip_cidr_range
    }
    cidr_blocks {
      cidr_block = "0.0.0.0/0" # Permite el acceso desde cualquier dirección IP (no recomendado para producción)
    }
  }
  default_max_pods_per_node = 50

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    network_policy_config {
      disabled = true
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.gke_options.node_pool_name
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = var.gke_options.node_pool_vm_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.sa-k8-lab.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_service_account" "sa-k8-lab" {
  account_id                   = "sa-k8-lab"
  display_name                 = "Service Account Kubernetes lab"
  create_ignore_already_exists = true
}

resource "google_service_account" "sa-cert-manager" {
  account_id                   = "sa-cert-manager"
  display_name                 = "Service Account certmanager Kubernetes lab"
  create_ignore_already_exists = true
}

resource "google_project_iam_member" "sa-cert-manager-iam-member" {
  project = var.project
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.sa-cert-manager.email}"
}


resource "google_service_account_key" "key" {
  service_account_id = google_service_account.sa-cert-manager.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
resource "local_file" "service_account" {
  content  = base64decode(google_service_account_key.key.private_key)
  filename = "${path.module}/output/sa-cert-manager.json"
}
