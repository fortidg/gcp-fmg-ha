locals {

  prefix = var.prefix

  region = var.region
  zone   = var.zone
  zone2  = var.zone2

  fortimanager_machine_type = var.fortimanager_machine_type
  fortimanager_vm_image     = var.fortimanager_vm_image


  fortimanager_license_files = var.fortimanager_license_files
  flex_tokens                = var.flex_tokens
  license_type               = var.license_type

  #######################
  # Static IPs
  #######################

  compute_addresses = {
    "fmg1-ext-ip" = {
      region       = local.region
      name         = "${local.prefix}-fmg1-ext-ip-${random_string.string.result}"
      subnetwork   = null
      address      = null
      address_type = "EXTERNAL"
    }
    "fmg2-ext-ip" = {
      region       = local.region
      name         = "${local.prefix}-fmg2-ext-ip-${random_string.string.result}"
      subnetwork   = null
      address      = null
      address_type = "EXTERNAL"
    }
    "fmg1-int-ip" = {
      region       = local.region
      name         = "${local.prefix}-fmg1-int-ip-${random_string.string.result}"
      subnetwork   = google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].id
      address      = null
      address_type = "INTERNAL"
    }
    "fmg2-int-ip" = {
      region       = local.region
      name         = "${local.prefix}-fmg2-int-ip-${random_string.string.result}"
      subnetwork   = google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].id
      address      = null
      address_type = "INTERNAL"
    }
  }

  #######################
  # Compute Networks
  #######################

  compute_networks = {
    "untrust-vpc" = {
      region                  = local.region
      name                    = "${local.prefix}-untrust-vpc-${random_string.string.result}"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
    }
  }
  #######################
  # Compute Subnets
  #######################

  compute_subnetworks = {
    "untrust-subnet-1" = {
      region        = local.region
      network       = google_compute_network.compute_network["untrust-vpc"].id
      name          = "${local.prefix}-untrust-subnet-${random_string.string.result}"
      ip_cidr_range = "10.15.0.0/24"
    }
  }

  #######################
  # Compute Firewalls
  #######################

  compute_firewalls = {
    "untrust-vpc-ingress" = {
      name               = format("%s-ingress", google_compute_network.compute_network["untrust-vpc"].name)
      network            = google_compute_network.compute_network["untrust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["209.40.123.3/32", "104.155.135.10/32"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
    "trust-internal-ingress" = {
      name               = format("%s-internal-ingress", google_compute_network.compute_network["untrust-vpc"].name)
      network            = google_compute_network.compute_network["untrust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["10.15.0.0/24"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
  }

  #######################
  # Compute disks
  #######################

  compute_disks = {
    "fmg1-logdisk" = {
      name = "fmg1-logdisk-${random_string.string.result}"
      size = 30
      type = "pd-standard"
      zone = local.zone
    }
    "fmg2-logdisk" = {
      name = "fmg2-logdisk-${random_string.string.result}"
      size = 30
      type = "pd-standard"
      zone = local.zone2
    }
  }

  #######################
  # Compute instances
  #######################

  compute_instances = {
    fmg1_instance = {
      name         = "${local.prefix}-fmg1-${random_string.string.result}"
      zone         = local.zone
      machine_type = local.fortimanager_machine_type

      can_ip_forward = "true"
      tags           = ["fmg1"]

      boot_disk_initialize_params_image = local.fortimanager_vm_image

      attached_disk = [{
        source = google_compute_disk.compute_disk["fmg1-logdisk"].name
      }]

      network_interface = [{
        network    = google_compute_network.compute_network["untrust-vpc"].name
        subnetwork = google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].name
        network_ip = google_compute_address.compute_address["fmg1-int-ip"].address
        access_config = [{
          nat_ip = google_compute_address.compute_address["fmg1-ext-ip"].address
        }]
      }]
      metadata = {
        user-data = data.template_file.template_file["fmg1-template"].rendered
      }
      service_account_scopes    = ["cloud-platform"]
      allow_stopping_for_update = true
    }

    fmg2_instance = {
      name         = "${local.prefix}-fmg2-${random_string.string.result}"
      zone         = local.zone2
      machine_type = local.fortimanager_machine_type

      can_ip_forward = "true"
      tags           = ["fmg2"]

      boot_disk_initialize_params_image = local.fortimanager_vm_image

      attached_disk = [{
        source = google_compute_disk.compute_disk["fmg2-logdisk"].name
      }]

      network_interface = [{
        network    = google_compute_network.compute_network["untrust-vpc"].name
        subnetwork = google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].name
        network_ip = google_compute_address.compute_address["fmg2-int-ip"].address
        access_config = [{
          nat_ip = google_compute_address.compute_address["fmg2-ext-ip"].address
        }]
      }]
      metadata = {
        user-data = data.template_file.template_file["fmg2-template"].rendered
      }
      service_account_scopes    = ["cloud-platform"]
      allow_stopping_for_update = true
    }
  }

  #######################
  # Template Files
  #######################

  template_files = {
    fmg1-template = {
      fmg_name      = "fmg1"
      template_file = "fmg.conf"
      port1_ip    = google_compute_address.compute_address["fmg1-int-ip"].address
      fmg_gw      = google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].gateway_address
      fmg_username = var.fmg_username
      fmg_password  = var.fmg_password
      license_type  = var.license_type
      license_token = local.flex_tokens[0] != "" ? local.flex_tokens[0] : null
      license_file  = local.fortimanager_license_files["fmg1_instance"].name != null ? file(local.fortimanager_license_files["fmg1_instance"].name) : null
    }
    fmg2-template = {
      fmg_name      = "fmg2"
      template_file = "fmg.conf"
      port1_ip    = google_compute_address.compute_address["fmg2-int-ip"].address
      fmg_gw       =  google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].gateway_address
      fmg_username = var.fmg_username
      fmg_password  = var.fmg_password
      license_type  = var.license_type
      license_token = local.flex_tokens[1] != "" ? local.flex_tokens[1] : null
      license_file  = local.fortimanager_license_files["fmg2_instance"].name != null ? file(local.fortimanager_license_files["fmg2_instance"].name) : null
    }
  }
}

