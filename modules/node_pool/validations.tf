module "validate_labels" {
  source = "git::https://github.com/Equifax/7265_GL_BILLING_IAAS.git?ref=v2.0.0"
  user_labels = merge(
    zipmap(
      flatten([for item in values(local.node_pools_labels) : keys(item)]),
      flatten([for item in values(local.node_pools_labels) : values(item)])
    )
  )
}
