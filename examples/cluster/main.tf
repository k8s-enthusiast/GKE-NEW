provider "google-beta" {
  version = ">= 3.28.0"
}

/******************************************
  dynamic value for creation of resources
 *****************************************/
resource "random_string" "name_suffix" {
  length  = 3
  upper   = false
  special = false
}

locals {
  project_id = "iaas-cdshr-cd1-dev-npe-9889"
  location   = "us-east1"
  labels = {
    "data_class"      = "4"
    "cost_center"     = "54932"
    "division"        = "4492"
    "cmdb_bus_svc_id" = "asve0003000"
  }
}


// Data for subnetwork
data "google_compute_subnetwork" "master_authorized_network" {
  name    = "iaas-platf-svcs-npe-gke-master"
  project = "efx-gcp-iaas-svpc-npe-de9c"
  region  = local.location
}


module "cluster" {
  source     = "../../modules/cluster"
  location   = local.location
  project_id = local.project_id
  name       = "iaas-cdshr-cd1-gke-${random_string.name_suffix.result}"
  network    = "projects/efx-gcp-iaas-svpc-npe-de9c/global/networks/iaas-net-npe"
  subnetwork = "projects/efx-gcp-iaas-svpc-npe-de9c/regions/us-east1/subnetworks/iaas-platf-svcs-npe-gke-master"

  database_encryption_key_name = "projects/sec-crypto-iam-npe-c8ed/locations/us-east1/keyRings/iaas-cdshr-cd1-dev-npe-9889_BAP0007265_cicd/cryptoKeys/iaas-gke-cluster-key"

  master_ipv4_cidr_block = "10.144.8.32/28"

  master_authorized_networks = [
    {
      cidr_block   = data.google_compute_subnetwork.master_authorized_network.ip_cidr_range // "10.149.172.192/27"
      display_name = data.google_compute_subnetwork.master_authorized_network.name          // "iaas-platf-svcs-npe-initial-npe-9"
    }
  ]

  resource_labels = local.labels

  dummy_nood_pool_sa_email = "tf-iaas-cdshr-cd1-dev-npe@iaas-cdshr-cd1-dev-npe-9889.iam.gserviceaccount.com"
}

output "cluster_name" {
  description = "GKE Cluster name"
  value       = module.cluster.name
}


module "node_pools" {
  source     = "../../modules/node_pool"
  cluster    = module.cluster.name
  location   = local.location
  project_id = local.project_id

  node_pools = [
    {
      name         = "iaas-cluster-node-pool"
      machine_type = "n1-standard-8"
      // boot_disk_kms_key = <CMEK for disk>
    },
    {
      name         = "iaas-cluster-node-pool-taint"
      machine_type = "n1-standard-8"
    },
  ]

  node_pools_labels = {
    "all"               = local.labels
    "default-node-pool" = {}
  }

  node_pools_taint = {
    "all"               = []
    "default-node-pool" = []
    "iaas-cluster-node-pool-taint" = [
      {
        effect = "NO_SCHEDULE"
        key    = "dedicated"
        value  = "experimental"
      }
    ]
  }

}

module "bastion" {
  source = "../../modules/bastion"

  // cluster info and configuration
  cluster_name                 = module.cluster.name
  cluster_project_id           = local.project_id
  non_masquerade_cidrs         = ["10.160.0.0/21", "10.160.8.0/24"]
  istio_enable_namespace_set   = ["cat-dev", "cat-qa", "dna-qa", "dna-dev", "ing-dev", "ing-qa", "key-dev", "key-qa", "prp-dev", "prp-qa", "intel-dev", "intel-qa"]
  istio_disabled_namespace_set = ["istio-system"]

  // subnetwork to create internal load balance
  network_project_id = "efx-gcp-iaas-svpc-npe-de9c"
  subnetwork         = "iaas-platf-svcs-npe-gke-master"
  region             = local.location


  // gce
  labels              = local.labels
  vpcControlsBoundary = "no-fedramp" //  "fedramp-npe"  //"fedramp"
  // network info
  compute_subnetwork = data.google_compute_subnetwork.master_authorized_network.name
  zone               = "us-east1-b"
  // network_project_id same that load balance

}
