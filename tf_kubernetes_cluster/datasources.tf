data "google_compute_network" "default" {
  name = "default"
}
data "google_compute_subnetwork" "default" {
  name = "default"
}
data "google_dns_managed_zone" "devops_cl" {
  name = "devops-cl"
}
