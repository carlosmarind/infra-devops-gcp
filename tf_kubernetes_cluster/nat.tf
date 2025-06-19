resource "google_compute_router" "nat_router" {
  name    = var.network_options.nat_router_name
  network = data.google_compute_network.default.name
  region  = var.region
}
resource "google_compute_router_nat" "nat" {
  name                               = var.network_options.nat_name
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
