output "service_account" {
  description = "default Service account used for nodes ( if the node pool have other SA configurated this SA will not be used ) "
  value       = local.service_account
}
