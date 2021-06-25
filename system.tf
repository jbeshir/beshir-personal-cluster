resource "google_service_account_key" "kubeip_serviceaccount_key" {
  service_account_id = module.cluster.kubeipserviceaccountid
}

module "system" {
  source     = "./system"
  providers = {
    kubernetes = kubernetes
  }
  kubeipserviceaccountprivatekey = base64decode(google_service_account_key.kubeip_serviceaccount_key.private_key)
  cluster-name = data.google_container_cluster.cluster.name

  # Maybe necessary to avoid incorrect ordering caused by dependency on module.cluster.cluster,
  # passing through data.google_container_cluster.cluster indirectly.
  # Without, some cases of attempts by terraform destroy to destroy things -after- the cluster were observed.
  depends_on = [module.cluster]
}