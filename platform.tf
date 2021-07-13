module "platform" {
  source     = "./platform"
  project    = var.project
  providers = {
    kubernetes = kubernetes
  }
  cluster-name = data.google_container_cluster.cluster.name

  # Maybe necessary to avoid incorrect ordering caused by dependency on module.cluster.cluster,
  # passing through data.google_container_cluster.cluster indirectly.
  # Without, some cases of attempts by terraform destroy to destroy things -after- the cluster were observed.
  depends_on = [module.cluster]
}