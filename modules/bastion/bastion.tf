// Data for subnetwork
data "google_compute_subnetwork" "cluster_subnet" {
  name    = var.subnetwork
  project = var.network_project_id
  region  = var.region
}
// Generate the IP for API proxy
resource "google_compute_address" "api-proxy-ip" {
  name         = "${var.cluster_name}-ip-address"
  project      = var.cluster_project_id
  subnetwork   = data.google_compute_subnetwork.cluster_subnet.self_link
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_disk" "boot_partition" {
  name                      = "${var.cluster_name}-gce-boot"
  type                      = "pd-ssd"
  zone                      = var.zone
  physical_block_size_bytes = 4096
  image                     = local.gce_image
  size                      = 100
  labels                    = local.labels
  project                   = var.cluster_project_id
}

resource "google_compute_instance" "default" {
  count                     = var.enable_bastion_host ? 1 : 0
  project                   = var.cluster_project_id
  name                      = "${var.cluster_name}-gce"
  machine_type              = "n1-standard-1"
  zone                      = var.zone
  allow_stopping_for_update = "true"
  tags                      = ["ssh", "${format("%s", element(split("-", var.zone), 0))}${format("%s", element(split("-", var.zone), 1))}-route"]

  metadata_startup_script = data.template_file.startup_script.rendered

  boot_disk {
    source = google_compute_disk.boot_partition.self_link
  }
  
  network_interface {
    subnetwork         = var.compute_subnetwork
    subnetwork_project = var.network_project_id
  }
  service_account {
    email = google_service_account.cluster_admin.*.email[0]
    scopes = [
      "compute-rw",
      "cloud-platform",
      "storage-rw",
      "userinfo-email",
    ]
  }

  labels = local.labels

  depends_on = [
    google_compute_address.api-proxy-ip,
    data.template_file.startup_script,
    google_service_account.cluster_admin
  ]
}
