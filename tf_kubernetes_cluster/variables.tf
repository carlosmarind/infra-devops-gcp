variable "project" {
  description = "Google Cloud Platform project ID"
  type        = string
}
variable "region" {
  description = "Google Cloud region"
  type        = string
}
variable "zone" {
  description = "Google Cloud zone"
  type        = string
}

variable "gke_options" {
  description = "GKE Options"
  type = object({
    cluster_name            = string
    node_pool_name          = string
    node_pool_vm_type       = string
    node_pool_count         = number
    node_pool_disk_type     = string
    node_pool_disk_size     = number
    enable_private_nodes    = bool
    enable_private_endpoint = bool
    master_ipv4_cidr_block  = string
  })
}
variable "network_options" {
  description = "Network Options"
  type = object({
    subnet_name        = string
    pods_cidr          = string
    svc_cidr           = string
    gke_node_cidr      = string
    nat_name           = string
    nat_router_name    = string
    ingress_ip_lb_name = string
  })
}
variable "startup_schedule" {
  description = "Horario cron para encender la VM."
  type        = string
  default     = "0 12 * * *"
}

variable "shutdown_schedule" {
  description = "Horario cron para apagar la VM."
  type        = string
  default     = "0 3 * * *"
}
