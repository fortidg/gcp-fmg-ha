data "template_file" "template_file" {
  for_each = local.template_files

  template = file("${path.module}/templates/${each.value.template_file}")
  vars = {
    fmg_name         = each.value.fmg_name
    port1_ip        = each.value.port1_ip
    fmg_gw          = each.value.fmg_gw
    fmg_username    = var.fmg_username
    fmg_password     = var.fmg_password
    license_type     = each.value.license_type
    license_file     = each.value.license_file
    license_token    = each.value.license_token
  }
}