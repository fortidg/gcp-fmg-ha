# FMG-IP
output "fmg1_ip" {
  value = format("https://%s", google_compute_address.compute_address["fmg1-ext-ip"].address)
}
output "fmg1_instance_id" {
  value = google_compute_instance.compute_instance["fmg1_instance"].instance_id
}

output "fmg2_ip" {
  value = format("https://%s", google_compute_address.compute_address["fmg2-ext-ip"].address)
}
output "fmg2_instance_id" {
  value = google_compute_instance.compute_instance["fmg2_instance"].instance_id
}

# FMG-Password
output "fmg_password" {
  value = var.fmg_password
}

