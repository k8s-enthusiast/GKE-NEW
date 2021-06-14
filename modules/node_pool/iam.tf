resource "random_string" "cluster_service_account_suffix" {
  upper   = false
  lower   = true
  special = false
  length  = 4
}

resource "google_service_account" "cluster_service_account" {
  count   = var.create_service_account ? 1 : 0
  project = var.project_id
  // get the first 27 characters of the cluster name
  // remove last character if is a '-'
  account_id   = "${trimsuffix(substr(var.cluster, 0, 27), "-")}-sa"
  display_name = "Terraform-managed service account for cluster ${var.cluster}"
}

resource "google_project_iam_member" "cluster_service_account-log_writer" {
  count   = var.create_service_account ? 1 : 0
  project = google_service_account.cluster_service_account[0].project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cluster_service_account[0].email}"
}

resource "google_project_iam_member" "cluster_service_account-metric_writer" {
  count   = var.create_service_account ? 1 : 0
  project = google_project_iam_member.cluster_service_account-log_writer[0].project
  role    = "organizations/552306434765/roles/efx.monitoringMetricWriter"
  member  = "serviceAccount:${google_service_account.cluster_service_account[0].email}"
}

resource "google_project_iam_member" "cluster_service_account-monitoring_viewer" {
  count   = var.create_service_account ? 1 : 0
  project = google_project_iam_member.cluster_service_account-metric_writer[0].project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cluster_service_account[0].email}"
}

resource "google_project_iam_member" "cluster_service_account-resourceMetadata-writer" {
  count   = var.create_service_account ? 1 : 0
  project = google_project_iam_member.cluster_service_account-monitoring_viewer[0].project
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.cluster_service_account[0].email}"
}
