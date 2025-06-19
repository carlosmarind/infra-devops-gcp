data "google_dns_managed_zone" "devops_cl" {
  name = "devops-cl"
}

resource "google_dns_record_set" "devops_cl" {
  name         = "${google_compute_instance.default.name}.${data.google_dns_managed_zone.devops_cl.dns_name}"
  managed_zone = data.google_dns_managed_zone.devops_cl.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.default.network_interface.0.access_config.0.nat_ip
  ]
}

resource "google_dns_record_set" "vm_hostname" {
  count        = length(var.users)
  name         = "vm-${count.index}.${data.google_dns_managed_zone.devops_cl.dns_name}"
  managed_zone = data.google_dns_managed_zone.devops_cl.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.default.network_interface.0.access_config.0.nat_ip
  ]
}