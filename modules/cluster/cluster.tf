resource "google_container_cluster" "primary" {
  provider = google-beta

  name        = var.name
  description = var.description
  project     = var.project_id

  resource_labels = merge(var.resource_labels, {
    terraform_module_version = "v1-8-0"
    terraform_module_git     = "github_com_equifax_7265_gl_gke_iaas"
    provisioned_by           = "terraform"
  })

  location        = var.location
  node_locations  = local.node_locations
  network         = var.network
  subnetwork      = var.subnetwork
  networking_mode = "VPC_NATIVE" // Added to avoid cluster creation error https://github.com/terraform-providers/terraform-provider-google/issues/6744

  enable_binary_authorization = true

  //GCP-GKE-030 - Logging
  logging_service = "logging.googleapis.com/kubernetes"
  //GCP-GKE-032 - Monitoring
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  default_max_pods_per_node = var.default_max_pods_per_node

  // Updated default as regular channel
  release_channel {
    channel = var.release_channel
  }

  //pod security policy config
  pod_security_policy_config {
    enabled = true
  }

  // GCP-GKE-010 - Traffic Controls
  network_policy {
    enabled = true
  }

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }


  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  // GCP-GKE-002 - Encryption
  database_encryption {
    state    = "ENCRYPTED"
    key_name = var.database_encryption_key_name
  }


  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }

    istio_config {
      disabled = ! var.istio
      auth     = "AUTH_MUTUAL_TLS"
    }

    dynamic "cloudrun_config" {
      for_each = local.cluster_cloudrun_config

      content {
        disabled = cloudrun_config.value.disabled
      }
    }

    // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#dns_cache_config
    // Enabling/Disabling NodeLocal DNSCache in an existing cluster is a disruptive operation. All cluster nodes running GKE 1.15 and higher are recreated.
    dns_cache_config {
      enabled = var.dns_cache
    }

  }


  dynamic "master_authorized_networks_config" {
    for_each = local.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  // Default maintenance window is on every Sunday
  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time = var.maintenance_end_time
      recurrence = var.recurrence
    }
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  dynamic "resource_usage_export_config" {
    for_each = var.resource_usage_export_dataset_id != "" ? [{
      enable_network_egress_metering       = var.enable_network_egress_export
      enable_resource_consumption_metering = var.enable_resource_consumption_export
      dataset_id                           = var.resource_usage_export_dataset_id
    }] : []

    content {
      enable_network_egress_metering       = resource_usage_export_config.value.enable_network_egress_metering
      enable_resource_consumption_metering = resource_usage_export_config.value.enable_resource_consumption_metering
      bigquery_destination {
        dataset_id = resource_usage_export_config.value.dataset_id
      }
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  node_config {
    service_account = var.dummy_nood_pool_sa_email
  }

  lifecycle {
    ignore_changes = [node_pool, node_config, initial_node_count]
  }

  notification_config {
    pubsub {
      enabled = var.notification_config_topic != "" ? true : false
      topic   = var.notification_config_topic
    }
  }
}
