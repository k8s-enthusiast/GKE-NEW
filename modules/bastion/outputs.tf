output "gke_cluster_endpoint_api_proxy" {
  description = "GKE Cluster API proxy to access actual endpoint"
  value       = "http://${google_compute_address.api-proxy-ip.address}:8443"
}
