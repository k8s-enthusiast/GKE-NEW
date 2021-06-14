data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.location
  status  = "UP"
}

resource "random_shuffle" "available_zones" {
  input        = data.google_compute_zones.available.names
  result_count = 3
}

locals {
  // for regional cluster - use var.zones if provided, use available otherwise, for zonal cluster use var.zones with first element extracted
  node_locations = coalescelist(compact(var.zones), sort(random_shuffle.available_zones.result))

  master_authorized_networks_config = length(var.master_authorized_networks) == 0 ? [] : [{
    cidr_blocks : var.master_authorized_networks
  }]

  cluster_cloudrun_config = var.cloudrun ? [{ disabled = false }] : []

}