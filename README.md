# Equifax Google GKE Terraform Modules

This Terraform module makes it easier to follow the Security Advisements for Google GKE.

[GKE Kubernetes Control Requirements](https://equifax.atlassian.net/wiki/spaces/SE/pages/602997270/GKE+Kubernetes)

## Compatibility

This module is meant for use with Terraform 0.12. 

## Terraform Provider

### node_pool 
* google = ">= 3.28.0"

### cluster
* google-beta = ">= 3.28.0"

### bastion
* google   = ">= 3.28.0"
* template = ">= 2.1.2"
    

## cluster Usage
```hcl-terraform
module "cluster" {
  source     = "git::https://github.com/Equifax/7265_GL_GKE_IAAS.git//modules/cluster?ref=v0.0.0"
  project_id = "df-sre-tools-npe-981e"
  location   = "us-east1"
  name       = "my-cluster-test"
  network    = "projects/efx-gcp-df-svpc-npe-0f3e/global/networks/df-net-npe"
  subnetwork = "projects/efx-gcp-df-svpc-npe-0f3e/regions/us-east1/subnetworks/df-sre-us-dev-npe-gke-nodes-9"

  database_encryption_key_name = "projects/sec-crypto-iam-npe-c8ed/locations/us-east1/keyRings/df-sre-tools-npe-fbfc_datafabric/cryptoKeys/df-us-dev-qa-new-key"

  master_ipv4_cidr_block = "10.142.4.0/28"

  master_authorized_networks = [
    {
      cidr_block   = "10.148.173.192/27"
      display_name = "df-sre-tools-npe-initial-npe"
    }
  ]

  resource_labels = {
    "data_class"      = "4"
    "cost_center"     = "54932"
    "division"        = "4492"
    "cmdb_bus_svc_id" = "asve0003000"
  }
  
  // this is to be used for the initial node pool creation that will be destroied after the cluster been created
  dummy_nood_pool_sa_email = "tf-df-sre-tools-npe@df-sre-tools-npe-981e.iam.gserviceaccount.com"

  //GKE upgrade notifications to a pubsub topic is disabled by default. If the variable is specified, it will be enabled. PUBSUB topic should exist before running this
  notification_config_topic = gke-notifications-topic
}
```

## Node pool Usage

### Multiple node pool
```hcl-terraform
module "node_pools" {
  source                 = "git::https://github.com/Equifax/7265_GL_GKE_IAAS.git//modules/node_pool?ref=v0.0.0"
  cluster                = "df-us-test-dev-rcr7"
  location               = "us-east1"
  project_id             = "df-sre-tools-npe-981e"
  service_account        = "df-us-test-dev-rcr7-sa@df-sre-tools-npe-981e.iam.gserviceaccount.com"
  create_service_account = false

  node_pools = [
    {
      "name"         = "test-1-node-pool"
      "machine_type" = "n1-standard-2"
    },
    {
      "name"         = "test-2-node-pool"
      "machine_type" = "n1-standard-2"
    },
  ]

  node_pools_labels = {
    "all" = {
      "data_class"      = "4"
      "cost_center"     = "54932"
      "division"        = "4492"
      "cmdb_bus_svc_id" = "asve0003000"
    }
    "default-node-pool" = {}
  }
}
```

### Single node pool with taint
```hcl-terraform
module "node_pools" {
  source                 = "git::https://github.com/Equifax/7265_GL_GKE_IAAS.git//modules/node_pool?ref=v0.0.0"
  cluster                = "df-us-test-dev-rcr7"
  location               = "us-east1"
  project_id             = "df-sre-tools-npe-981e"
  service_account        = "df-us-test-dev-rcr7-sa@df-sre-tools-npe-981e.iam.gserviceaccount.com"
  create_service_account = false
  
  grant_registry_access  = true
  gcr_bucket_name        = "us.artifacts.iaas-gcr-reg-prd-ad3d.appspot.com"

  node_pools = [
    {
      "name"             = "test-node-pool"
      "machine_type"     = "n1-standard-2"
       max_pods_per_node = "32"
    },
  ]

  node_pools_labels = {
    "all" = {
      "data_class"      = "4"
      "cost_center"     = "54932"
      "division"        = "4492"
      "cmdb_bus_svc_id" = "asve0003000"
    }
    "default-node-pool" = {}
  }

  node_pools_taint = {
    "all"               = []
    "default-node-pool" = []
    "test-node-pool" = [
      {
        effect = "NO_SCHEDULE"
        key    = "dedicated"
        value  = "experimental"
      }
    ]
  }
}
```


## Bastion Usage

```hcl-terraform

module "bastion" {
  source = "git::https://github.com/Equifax/7265_GL_GKE_IAAS.git//modules/bastion?ref=v0.0.0"

  // cluster info and configuration
  cluster_name                 = module.cluster.name
  cluster_project_id           = "df-sre-tools-npe-981e"
  non_masquerade_cidrs         = ["10.96.0.0/19", "10.161.148.0/22"]
  istio_enable_namespace_set   = ["cat-dev", "cat-qa", "dna-qa", "dna-dev", "ing-dev", "ing-qa", "key-dev", "key-qa", "prp-dev", "prp-qa", "intel-dev", "intel-qa"]
  istio_disabled_namespace_set = ["istio-system"]

  // subnetwork to create internal load balance
  network_project_id = "efx-gcp-df-svpc-npe-0f3e"
  subnetwork         = "df-sre-us-dev-npe-gke-nodes-9"
  region             = "us-east1"


  // gce
  labels = local.labels
  // network info
  compute_subnetwork = "df-sre-tools-npe-initial-npe"
  zone               = "us-east1-b"
  // network_project_id same that load balance

}
```
