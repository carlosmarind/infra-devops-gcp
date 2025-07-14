variable "project" {
  type = string
}
variable "region" {
  type = string
}
variable "zone" {
  type = string
}
variable "vm_tag" {
  type = string
}
variable "vm_name" {
  type = string
}
variable "vm_type" {
  type = string
}
variable "disk_size" {
  type = number
}
variable "vm_password" {
  type        = string
  description = "password para ingresar como usuario"
  sensitive   = true
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
