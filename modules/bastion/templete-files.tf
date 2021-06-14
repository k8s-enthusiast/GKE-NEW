// Render the deployment yaml file for API proxy setup
data "template_file" "api-proxy-deployment" {
  template = file("${path.module}/k8s_templates/api-proxy-deployment.yaml")

  vars = {
    k8s_api_proxy_image = "gcr.io/iaas-gcr-reg-prd-ad3d/golden/iaas/k8s-api-proxy"
    k8s_api_proxy_tag   = "1.0-alpine"
  }
}

data "template_file" "api-proxy-service" {
  template = file("${path.module}/k8s_templates/api-proxy-service.yaml")
  vars = {
    internal_loadbalancer_ip = google_compute_address.api-proxy-ip.address
  }
}

data "template_file" "pod_security_policy_yaml" {
  template = file("${path.module}/k8s_templates/psp-restricted.yaml")
}

data "template_file" "ip_masq_agent_yaml" {
  template = file("${path.module}/k8s_templates/ip-masq-agent.yaml")
}

data "template_file" "startup_script" {
  template = file("${path.module}/scripts/cluster-admin-startup.sh")

  vars = {
    cluster_name                 = var.cluster_name
    region                       = var.region
    project                      = var.cluster_project_id
    deployment_yaml              = data.template_file.api-proxy-deployment.rendered
    service_yaml                 = data.template_file.api-proxy-service.rendered
    pod_security_policy_yaml     = data.template_file.pod_security_policy_yaml.rendered
    istio_enable_namespace_set   = join(",", var.istio_enable_namespace_set)
    istio_disabled_namespace_set = join(",", var.istio_disabled_namespace_set)
    // TODO improve this step by getting the values form *data.google_compute_subnetwork.cluster_subnet.secondary_ip_range*
    non_masquerade_cidrs     = join(",", var.non_masquerade_cidrs)
    ip_masq_agent_yaml       = data.template_file.ip_masq_agent_yaml.rendered
    internal_loadbalancer_ip = google_compute_address.api-proxy-ip.address
  }
}
