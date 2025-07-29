resource "random_string" "string" {
  length           = 3
  special          = true
  override_special = ""
  min_lower        = 3
}

resource "google_compute_address" "compute_address" {
  for_each = local.compute_addresses

  name         = each.value.name
  region       = each.value.region
  address_type = each.value.address_type
  subnetwork   = each.value.subnetwork
  address      = each.value.address
}

resource "google_compute_network" "compute_network" {
  for_each = local.compute_networks

  name                    = each.value.name
  auto_create_subnetworks = each.value.auto_create_subnetworks
  routing_mode            = each.value.routing_mode
}

resource "google_compute_subnetwork" "compute_subnetwork" {
  for_each = local.compute_subnetworks

  region        = each.value.region
  network       = each.value.network
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
}

resource "google_compute_firewall" "compute_firewall" {
  for_each = local.compute_firewalls

  name               = each.value.name
  network            = each.value.network
  direction          = each.value.direction
  source_ranges      = each.value.source_ranges
  destination_ranges = each.value.destination_ranges

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
    }
  }
}

resource "google_compute_disk" "compute_disk" {
  for_each = local.compute_disks

  name = each.value.name
  size = each.value.size
  type = each.value.type
  zone = each.value.zone
}

resource "google_compute_instance" "compute_instance" {
  for_each = local.compute_instances

  name         = each.value.name
  zone         = each.value.zone
  machine_type = each.value.machine_type

  can_ip_forward = each.value.can_ip_forward
  tags           = each.value.tags

  boot_disk {
    initialize_params {
      image = each.value.boot_disk_initialize_params_image
    }
  }

  dynamic "attached_disk" {
    for_each = each.value.attached_disk
    content {
      source = attached_disk.value.source
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interface
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork
      network_ip = network_interface.value.network_ip
      dynamic "access_config" {
        for_each = network_interface.value.access_config
        content {
          nat_ip = access_config.value.nat_ip
        }
      }
    }
  }

  metadata = each.value.metadata

  service_account {
    scopes = each.value.service_account_scopes
  }

  allow_stopping_for_update = each.value.allow_stopping_for_update
}



# # Enable outbound connectivity via Cloud NAT
# resource "google_compute_router" "nat_router" {
#   name    = "${var.prefix}-cr-nat-${random_string.string.result}"
#   region  = var.region
#   network = google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].network
# }

# resource "google_compute_router_nat" "cloud_nat" {
#   name                               = "${var.prefix}nat-cloudnat-${var.region}"
#   router                             = google_compute_router.nat_router.name
#   region                             = var.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#   subnetwork {
#     name                    = google_compute_subnetwork.compute_subnetwork["untrust-subnet-1"].self_link
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#   }
# }

#enable all traffic to ilb
