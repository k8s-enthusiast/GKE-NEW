variable "project_id" {
  type        = string
  description = "(Required) The project ID to host the cluster in"
}

variable "name" {
  type        = string
  description = "(Required) The name of the cluster"
}

variable "description" {
  type        = string
  description = "The description of the cluster"
  default     = ""
}

variable "network" {
  type        = string
  description = "(Required) The VPC network to host the cluster in"
}

variable "location" {
  type        = string
  description = "(Required) The location to host the cluster in"
}

variable "database_encryption_key_name" {
  type        = string
  description = "(Required) the key to use to encrypt/decrypt secrets. See the DatabaseEncryption definition for more information."
}

variable "resource_labels" {
  type        = map(string)
  description = "(Required) The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
}

variable "subnetwork" {
  type        = string
  description = "(Required) The subnetwork to host the cluster in (required)"
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "(Required) List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "(Required) The IP range in CIDR notation to use for the hosted master network"
}

variable "dummy_nood_pool_sa_email" {
  type        = string
  description = "(Required) Service account used for run temporaty node pool creation ( this will be removed after the cluster been provision )"
}

variable "ip_range_pods" {
  type        = string
  description = "The _name_ of the secondary subnet ip range to use for pods"
  default     = "pods" // default name created by IaaS Shared VPC provision
}

variable "ip_range_services" {
  type        = string
  description = "The _name_ of the secondary subnet range to use for services"
  default     = "service" // default name created by IaaS Shared VPC provision
}


variable "zones" {
  type        = list(string)
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
  default     = []
}

variable "default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node"
  default     = 64
}

variable "maintenance_start_time" {
  type        = string
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"
  default     = "2020-11-25T05:00:00Z"
}
variable "maintenance_end_time" {
  type        = string
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"
  default     = "2020-11-26T11:00:00Z"
}

variable "release_channel" {
  type        = string
  description = "Release channel specified regular as default"
  default     = "REGULAR"
}

variable "recurrence" {
  type        = string
  description = "Release channel specified regular as default"
  default     = "FREQ=WEEKLY;BYDAY=SU"
}

variable "resource_usage_export_dataset_id" {
  type        = string
  description = "The ID of a BigQuery Dataset for using BigQuery as the destination of resource usage export."
  default     = ""
}

variable "enable_network_egress_export" {
  type        = bool
  description = "Whether to enable network egress metering for this cluster. If enabled, a daemonset will be created in the cluster to meter network egress traffic."
  default     = false
}

variable "enable_resource_consumption_export" {
  type        = bool
  description = "Whether to enable resource consumption metering on this cluster. When enabled, a table will be created in the resource export BigQuery dataset to store resource consumption data. The resulting table can be joined with the resource usage table or with BigQuery billing export."
  default     = true
}



variable "cloudrun" {
  description = "(Beta) Enable CloudRun addon"
  default     = false
}

variable "istio" {
  description = "(Beta) Enable Istio addon"
  default     = false
}

variable "dns_cache" {
  description = "(Beta) Enable NodeLocal DNSCache addon"
  default     = false
}

variable "notification_config_topic" {
  type        = string
  description = "The desired Pub/Sub topic to which notifications will be sent by GKE. Format is projects/{project}/topics/{topic}."
  default     = ""
}
