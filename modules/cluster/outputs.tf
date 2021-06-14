output "name" {
  description = "GKE Cluster name"
  value       = lookup(google_container_cluster.primary, "name", var.name)
}