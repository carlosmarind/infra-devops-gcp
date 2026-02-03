resource "google_dns_managed_zone" "devops_cl" {
  name          = "devops-cl"
  dns_name      = "devops.cl."
  description   = "devops.cl Public DNS zone"
  force_destroy = "false"
}

resource "google_service_account" "sa-dns-manager" {
  account_id                   = "sa-dns-manager"
  display_name                 = "Service Account certmanager Kubernetes lab"
  create_ignore_already_exists = true
}

resource "google_project_iam_member" "sa-dns-manager-iam-member" {
  project = var.project
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.sa-dns-manager.email}"
}


resource "google_service_account_key" "key" {
  service_account_id = google_service_account.sa-dns-manager.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}
resource "local_file" "service_account" {
  content  = base64decode(google_service_account_key.key.private_key)
  filename = "${path.module}/output/sa-dns-manager.json"
}
