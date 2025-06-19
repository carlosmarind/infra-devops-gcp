resource "google_dns_managed_zone" "devops_cl" {
  name          = "devops-cl"
  dns_name      = "devops.cl."
  description   = "devops.cl Public DNS zone"
  force_destroy = "false"
}