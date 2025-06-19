resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.vm-type
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2204-jammy-v20240829"
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip_address.address
    }
  }
  metadata_startup_script = templatefile("scripts/startup.sh", {
    users           = var.users,
    password_suffix = var.ssh_password,
  })
  tags = [var.vm_tag]
  lifecycle {
    ignore_changes = [
      resource_policies # Esto le dice a Terraform que no intente gestionar este atributo aquí.
    ]
  }
}
