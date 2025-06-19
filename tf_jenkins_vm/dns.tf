resource "google_compute_address" "ip_global_jenkins" {
  name         = "ip-global-${var.vm_name}"
  address_type = "EXTERNAL"
}
resource "google_dns_record_set" "jenkins_devops_cl" {
  name         = "${var.vm_name}.${data.google_dns_managed_zone.devops_cl.dns_name}"
  managed_zone = data.google_dns_managed_zone.devops_cl.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_address.ip_global_jenkins.address
  ]
}

