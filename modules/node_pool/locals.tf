locals {
  cluster_network_tag = "gke-${var.cluster}"

  // Build a map of maps of node pools from a list of objects
  node_pool_names = [for np in toset(var.node_pools) : np["name"]]
  node_pools      = zipmap(local.node_pool_names, tolist(toset(var.node_pools)))

  node_pools_labels = merge(
    { all = {} },
    { default-node-pool = {} },
    zipmap(
      local.node_pool_names,
      [for node_pool in var.node_pools : {}]
    ),
    var.node_pools_labels
  )

  node_pools_metadata = merge(
    { all = {} },
    { default-node-pool = {} },
    zipmap(
      [for node_pool in var.node_pools : node_pool["name"]],
      [for node_pool in var.node_pools : {}]
    ),
    var.node_pools_metadata
  )

  node_pools_tags = merge(
    { all = [] },
    { default-node-pool = [] },
    zipmap(
      [for node_pool in var.node_pools : node_pool["name"]],
      [for node_pool in var.node_pools : []]
    ),
    var.node_pools_tags
  )

  node_pools_oauth_scopes = merge(
    { all = [] },
    { default-node-pool = [] },
    zipmap(
      [for node_pool in var.node_pools : node_pool["name"]],
      [for node_pool in var.node_pools : []]
    ),
    var.node_pools_oauth_scopes
  )

  node_pools_taint = merge(
    { all = [] },
    { default-node-pool = [] },
    zipmap(
      [for node_pool in var.node_pools : node_pool["name"]],
      [for node_pool in var.node_pools : []]
    ),
    var.node_pools_taint
  )

  service_account_list = compact(
    concat(
      google_service_account.cluster_service_account.*.email,
      ["dummy"],
    ),
  )
  // if user set var.service_accont it will be used even if var.create_service_account==true, so service account will be created but not used
  service_account = (var.service_account == "" || var.service_account == "create") && var.create_service_account ? local.service_account_list[0] : var.service_account
}