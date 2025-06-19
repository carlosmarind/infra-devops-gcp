data "google_iam_policy" "admin" {
  binding {
    role = "roles/artifactregistry.repoAdmin"
    members = [
      google_service_account.sa-registry.member
    ]
  }
}
