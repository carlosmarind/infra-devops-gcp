resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.vm_type
  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2204-jammy-v20240829"
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.ip_global_jenkins.address
    }
  }
  metadata_startup_script = templatefile("scripts/startup.sh", {
    password = var.vm_password
    domain   = "${var.vm_name}.devops.cl"
  })
  metadata = {
    ssh-keys = "carlosmarind:${file("~/.ssh/id_rsa.pub")}"
  }
  tags = [var.vm_tag]
}
