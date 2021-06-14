resource "google_container_node_pool" "pools" {
  provider = google-beta
  for_each = local.node_pools
  name     = each.key
  project  = var.project_id
  location = var.location

  cluster = var.cluster
  

  initial_node_count = lookup(each.value, "autoscaling", true) ? lookup(
    each.value,
    "initial_node_count",
    lookup(each.value, "min_count", 1)
  ) : null

  max_pods_per_node = lookup(each.value, "max_pods_per_node", 16)

  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling", true) ? [each.value] : []
    content {
      min_node_count = lookup(autoscaling.value, "min_count", 1)
      max_node_count = lookup(autoscaling.value, "max_count", 100)
    }
  }

  management {
    // GCP-GKE-035 - Data Recovery
    auto_repair = true
    // GCP-GKE-008 - Patching
    auto_upgrade = true
  }


  node_config {
    // GCP-GKE-006 - Patch Management
    image_type   = "COS"
    machine_type = lookup(each.value, "machine_type", "n1-standard-16")

    labels = merge(
      lookup(lookup(local.node_pools_labels, "default_values", {}), "cluster_name", true) ? { "cluster_name" = var.cluster } : {},
      lookup(lookup(local.node_pools_labels, "default_values", {}), "node_pool", true) ? { "node_pool" = each.value["name"] } : {},
      local.node_pools_labels["all"],
      local.node_pools_labels[each.value["name"]],
      {
        terraform_module_git = "github_com_equifax_7265_gl_gke_iaas"
        provisioned_by       = "terraform"
        // Change log v1.1.1
        // remove module version of the node pool labels
        // this will force node pool rebuild for every new version of the module
        //terraform_module_version = ""
      }
    )

    metadata = merge(
      lookup(lookup(local.node_pools_metadata, "default_values", {}), "cluster_name", true) ? { "cluster_name" = var.cluster } : {},
      lookup(lookup(local.node_pools_metadata, "default_values", {}), "node_pool", true) ? { "node_pool" = each.value["name"] } : {},
      local.node_pools_metadata["all"],
      local.node_pools_metadata[each.value["name"]],
      {
        "disable-legacy-endpoints" = true
      },
    )

    tags = concat(
      lookup(local.node_pools_tags, "default_values", [true, true])[0] ? [local.cluster_network_tag] : [],
      lookup(local.node_pools_tags, "default_values", [true, true])[1] ? ["${local.cluster_network_tag}-${each.value["name"]}"] : [],
      local.node_pools_tags["all"],
      local.node_pools_tags[each.value["name"]],
    )

    local_ssd_count = lookup(each.value, "local_ssd_count", 0)
    disk_size_gb    = lookup(each.value, "disk_size_gb", 100)
    disk_type       = lookup(each.value, "disk_type", "pd-standard")

    service_account = lookup(
      each.value,
      "service_account",
      local.service_account,
    )
    preemptible = lookup(each.value, "preemptible", false)

    oauth_scopes = concat(
      ["https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring"],
      local.node_pools_oauth_scopes["all"],
      local.node_pools_oauth_scopes[each.value["name"]],
    )

    guest_accelerator = [
      for guest_accelerator in lookup(each.value, "accelerator_count", 0) > 0 ? [{
        type  = lookup(each.value, "accelerator_type", "")
        count = lookup(each.value, "accelerator_count", 0)
        }] : [] : {
        type  = guest_accelerator["type"]
        count = guest_accelerator["count"]
      }
    ]

    taint = concat(
      local.node_pools_taint["all"],
      local.node_pools_taint[each.value["name"]],
    )

    boot_disk_kms_key = lookup(each.value, "boot_disk_kms_key", "")

    shielded_instance_config {
      enable_secure_boot          = lookup(each.value, "enable_secure_boot", false)
      enable_integrity_monitoring = lookup(each.value, "enable_integrity_monitoring", true)
    }
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      instance_group_urls,
      name_prefix,
      node_count,
      node_locations,
      version,
      node_config["sandbox_config"],
      node_config["workload_metadata_config"]
    ]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

}
