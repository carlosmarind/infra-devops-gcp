output "gke_cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}
output "gke_cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = google_container_cluster.primary.endpoint
}
output "gke_cluster_master_version" {
  description = "The master Kubernetes version of the GKE cluster"
  value       = google_container_cluster.primary.master_version
}

output "gke_cluster_location" {
  description = "Región/Zona del cluster GKE."
  value       = google_container_cluster.primary.location 
}

output "gke_cluster_lb_ingress" {
  description = "Direccion ip para utilizar en el ingress de nginx"
  value       = google_compute_address.lb-ip-ingress.address
}