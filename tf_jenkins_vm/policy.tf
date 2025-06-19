resource "google_compute_resource_policy" "active_schedule_policy" {
  name   = "${var.vm_name}-active-policy"
  region = var.region

  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.startup_schedule
    }
    vm_stop_schedule {
      schedule = var.shutdown_schedule
    }
    time_zone = "America/Santiago" # Ajusta a tu zona horaria
  }
}

resource "google_compute_resource_policy_attachment" "attachment" {
  name     = google_compute_resource_policy.active_schedule_policy.name
  instance = google_compute_instance.default.name
  zone     = var.zone
}