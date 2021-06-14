resource "google_service_account" "cluster_admin" {
  count        = var.enable_bastion_host ? 1 : 0
  account_id   = "${var.cluster_name}-gce"
  display_name = "${var.cluster_name} - Bastion host"
  project      = var.cluster_project_id
}

resource "google_project_iam_member" "cluster_admin_container_admin" {
  count      = var.enable_bastion_host ? 1 : 0
  project    = var.cluster_project_id
  role       = "organizations/552306434765/roles/efx.gkeClusterAdmin"
  member     = "serviceAccount:${google_service_account.cluster_admin.*.email[0]}"
  depends_on = [google_service_account.cluster_admin]
}

resource "google_project_iam_member" "cluster_admin_container_viewer" {
  count      = var.enable_bastion_host ? 1 : 0
  project    = var.cluster_project_id
  role       = "organizations/552306434765/roles/efx.gkeViewer"
  member     = "serviceAccount:${google_service_account.cluster_admin.*.email[0]}"
  depends_on = [google_service_account.cluster_admin]
}

resource "google_project_iam_member" "loadbalancer_admin" {
  count      = var.enable_bastion_host ? 1 : 0
  project    = var.cluster_project_id
  role       = "organizations/552306434765/roles/efx.loadBalancerAdmin"
  member     = "serviceAccount:${google_service_account.cluster_admin.*.email[0]}"
  depends_on = [google_service_account.cluster_admin]
}
