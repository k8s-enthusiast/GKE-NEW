# v1.8.0
* Updated IAM role bindings in response to required changes. [See here for more info.](https://equifax.atlassian.net/wiki/spaces/IAMS/pages/591955712/Access+Groups+-+IAM+Roles+-+Proposed+Changes-v2)

# v1.7.2
* Updated IAM role binding according to new roles. GCR access is now being provided at bucket level. 

# v1.7.1
* Updated IAM role bindings in response to required changes. [See here for more info.](https://equifax.atlassian.net/wiki/spaces/IAMS/pages/591955712/Access+Groups+-+IAM+Roles+-+Proposed+Changes-v2)

# v1.7.0
* Enabled pubsub notification to to recieve GKE upgrade notifications to the pubsub topic

#  v1.6.0

* Updated default as regular channel
* Updated default maintenance window to every Sunday

#  v1.5.4

* Added labels to the bastion VM boot disk
* Cleaned up bitbucket references

#  v1.5.3

* Updating the add common validation for label see [terraform-module-efx-billing-label]
(https://github.com/Equifax/7265_GL_BILLING_IAAS.git)  
* Added the global github credentials
* Cleaned up bitbucket and on-prem confluence references

#  v1.5.2

* Remove namespace creation and labeling from bastion host startup script.
https://equifax.atlassian.net/browse/DFCS-1240


# v1.5.1

* Update provider to google-beta in node-pool.tf to support boot_disk_kms_key
more info:
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#boot_disk_kms_key

#  v1.5.0

* add boot_disk_kms_key options

more info:
https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/pull/516

* Add annotations networking.gke.io/internal-load-balancer-allow-global-access: "true" to k8s proxy service template. This will   enable global access to the load balancer which attached to the k8s proxy service.

Details information can be found here:
https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balancing#global_access

#  v1.4.2

* adding dns cache addon

#  v1.4.1

* fix error on node_pool module related with zone and region parameters

#  v1.4.0

* Switching to Golden/approved image built by IAAS team(Rob Cannon's team).

#  v1.3.0

* Revert add support for NPE Central GCR for FedRamp NPE k8S api proxy docker image
  * "gcr.io/eops-gcr-reg-npe-9959/k8s-api-proxy:v6" -> for FedRamp NPE
  * "us.gcr.io/iaas-gcr-reg-prd-ad3d/k8s-api-proxy:v7" -> Non-FedRamp and FedRamp Prod

#  v1.2.0

* Add support for fedRamp GCE source images
  * sec-eng-images-prd-5d4d/efx-centos-7 -> NPE and PROD
  * sec-img-fr-prd-7b82/efx-fr-centos-7  -> for FedRamp PROD
  * sec-dvop-fr-crt-npe-43bb/efx-fr-centos-7  -> for FedRamp NPE

* Add support for NPE Central GCR for FedRamp NPE k8S api proxy docker image
  * "gcr.io/eops-gcr-reg-npe-9959/k8s-api-proxy:v6" -> for FedRamp NPE
  * "us.gcr.io/iaas-gcr-reg-prd-ad3d/k8s-api-proxy:v7" -> Non-FedRamp and FedRamp Prod

#  v1.1.1

* remove module version of the node pool labels

this is force node pool rebuild for every new version of the module


#  v1.1.0

* changed nodel-pool sa to match with cluster name  
* added pod security policy
* block gke proxy image and version for the bastion module
* reduced default node_pools_oauth_scopes from "https://www.googleapis.com/auth/cloud-platform" -> "https://www.googleapis.com/auth/devstorage.read_only"

#  v1.0.0

* refactoring existent modules
https://bitbucket.equifax.com/projects/GCPTF/repos/terraform-efx-gke/browse
https://bitbucket.equifax.com/projects/GCPTF/repos/terraform-efx-gke-bastion/browse

with the following requirements
* Modular - cluster, nodepool, bastion
* Semantic Versioning
* Refactoring concern to not have module variables on the main.tf for the security controls
* GKE version - release channels configuration	- Static version prevents auto patching of master minor version that prevents latest node pools patching
* Module nodepool - feature Node taints - Workload isolation strategy	When you schedule workloads to be deployed on your cluster, node taints help you control which nodes they are allowed to run on.
