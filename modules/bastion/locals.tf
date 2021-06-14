locals {
  labels = merge(var.labels, {
    terraform_module_version = "v1-8-0"
    terraform_module_git     = "github_com_equifax_7265_gl_gke_iaas"
    provisioned_by           = "terraform"
  })

  gce_images = {
    fedramp-npe = "sec-dvop-fr-crt-npe-43bb/efx-fr-centos-7"
    fedramp     = "sec-img-fr-prd-7b82/efx-fr-centos-7"
    no-fedramp  = "sec-eng-images-prd-5d4d/efx-centos-7"
  }
  gce_image = local.gce_images[var.vpcControlsBoundary]
}
