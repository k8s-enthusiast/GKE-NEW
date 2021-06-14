variable "project_id" {
  type        = string
  description = "(Required) The project ID to host the cluster in."
}

variable "cluster" {
  type        = string
  description = "(Required) The cluster to create the node pool for. Cluster must be present in location provided for zonal clusters."
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in `node_pools`."
  default     = ""
}

variable "location" {
  type        = string
  description = "(Optional) The location (region or zone) of the cluster."
}

variable "node_pools" {
  type        = list(map(string))
  description = "List of maps containing node pools"

  default = [
    {
      name = "default-node-pool"
    },
  ]
}

variable "node_pools_labels" {
  type        = map(map(string))
  description = "Map of maps containing node labels by node-pool name"

  # Default is being set in locals.tf
  default = {
    all               = {}
    default-node-pool = {}
  }
}

variable "node_pools_metadata" {
  type        = map(map(string))
  description = "Map of maps containing node metadata by node-pool name"

  # Default is being set in locals.tf
  default = {
    all               = {}
    default-node-pool = {}
  }
}

variable "node_pools_tags" {
  type        = map(list(string))
  description = "Map of lists containing node network tags by node-pool name"

  # Default is being set in locals.tf
  default = {
    all = [
      "healthcheck", // need for loadbalanced healthcheck see https://jira.equifax.com/browse/DFCS-269
    ]
    default-node-pool = []
  }
}

variable "node_pools_oauth_scopes" {
  type        = map(list(string))
  description = "Map of lists containing node oauth scopes by node-pool name"

  # Default is being set in locals.tf
  default = {
    all = [
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
    default-node-pool = []
  }
}


variable "node_pools_taint" {
  type        = map(list(object({ effect : string, key : string, value : string })))
  description = "Map of lists containing taint by node-pool name"

  # Default is being set in locals.tf
  default = {
    all               = []
    default-node-pool = []
  }
}


variable "create_service_account" {
  type        = bool
  description = "Defines if service account specified to run nodes should be created."
  default     = true
}
