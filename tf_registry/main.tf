## Artifact Registry
resource "google_artifact_registry_repository" "docker-repository" {
  location      = var.region
  repository_id = "docker-repository"
  description   = "docker repository for container classroom"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}

resource "google_service_account" "sa-registry" {
  account_id                   = "sa-registry"
  project                      = var.project
  display_name                 = "Service Account for Artifact Registry"
  create_ignore_already_exists = true
}

resource "google_artifact_registry_repository_iam_policy" "policy" {
  project     = google_artifact_registry_repository.docker-repository.project
  location    = google_artifact_registry_repository.docker-repository.location
  repository  = google_artifact_registry_repository.docker-repository.name
  policy_data = data.google_iam_policy.admin.policy_data
}
resource "google_service_account_key" "key" {
  service_account_id = google_service_account.sa-registry.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
resource "local_file" "service_account_decoded" {
  content  = base64decode(google_service_account_key.key.private_key)
  filename = "${path.module}/output/sa-registry.json"
}