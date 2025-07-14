
variable "project" {
  type = string
}
variable "region" {
  type = string
}
variable "zone" {
  type = string
}
variable "vm-type" {
  type = string
}
variable "disk_size" {
  type = number
}
variable "instance_name" {
  type = string
}
variable "users" {
  type = list(any)
}
variable "ssh_password" {
  description = "password para ingresar como usuario"
  type        = string
  sensitive   = true
}
variable "vm_tag" {
  type = string
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
