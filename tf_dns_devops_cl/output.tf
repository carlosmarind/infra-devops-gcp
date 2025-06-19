output "nameservers" {
  description = "Listado de servidores dns gestionados por google cloud"
  value       = google_dns_managed_zone.devops_cl.name_servers
}
