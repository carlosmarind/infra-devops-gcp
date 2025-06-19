resource "google_compute_firewall" "lab-servers" {
  name    = "default-allow-ssh-terraform-labs"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443","3000-3030","8000-8030"]
  }
  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.vm_tag]
}

resource "google_compute_address" "static_ip_address" {
  name         = "${var.instance_name}-ip" # Un nombre descriptivo para tu IP estática
  region       = var.region                # La región donde se desplegará la IP (debe coincidir con la VM)
  address_type = "EXTERNAL"                # Por defecto, pero es bueno ser explícito
}
