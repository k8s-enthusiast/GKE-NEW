variable "enable_bastion_host" {
  default = true
  type    = bool
}

variable "cluster_name" {
  description = ""
}

variable "cluster_project_id" {
  description = "The project ID to host the cluster in (required)"
}

variable "compute_subnetwork" {
}

variable "subnetwork" {
}

variable "region" {
  description = "The region to host the cluster in (required)"
}

variable "zone" {
}

variable "network_project_id" {
  description = "The project ID for the network"
}

variable "istio_enable_namespace_set" {
  type = list(string)
}

variable "istio_disabled_namespace_set" {
  type = list(string)
}

variable "non_masquerade_cidrs" {
  type = list
}

variable "labels" {
}

variable "vpcControlsBoundary" {
  default     = "no-fedramp"
  description = "Possible values 'no-fedramp' , 'fedramp', 'fedramp-npe'. Default 'no-fedramp' "
  type        = string
}