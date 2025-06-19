output "public_ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
output "public_dns" {
  value = google_dns_record_set.devops_cl.name
}
output "public_dns_record_value" {
  value = google_dns_record_set.devops_cl.rrdatas
}
