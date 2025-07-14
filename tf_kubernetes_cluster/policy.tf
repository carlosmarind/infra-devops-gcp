resource "google_compute_resource_policy" "gke_node_schedule" {
  name     = "${var.gke_options.node_pool_name}-active-policy"
  region   = var.region

  instance_schedule_policy {
    vm_start_schedule {
      schedule =  var.startup_schedule
    }

    vm_stop_schedule {
      schedule = var.shutdown_schedule
    }

    time_zone = "America/Santiago"
  }
}

## para aplicar con gcloud
# gcloud compute instances list --zones=us-west1-a --filter="labels.schedule-group=lab-node-pool-group" --format="value(name,zone)" | while read name zone; do
#   gcloud compute instances add-resource-policies "$name" \
#     --zone="$zone" \
#     --resource-policies="lab-node-pool-active-policy"
# done