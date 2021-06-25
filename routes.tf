module "routes" {
  source                             = "./routes"
  crds = module.crds.crds
  ingress-routes-crd-version         = module.crds.ingressroutescrdversion
  persistent-secrets-bucket-name     = "${var.project}-${data.google_project.project.number}-persistent-secrets"
  persistent-secrets-bucket-contents = var.persistent-secrets-bucket-contents # Used to introduce a dependency for tests.
  ethtruism-namespace-name      = module.services.ethtruism-namespace-name
  ethtruism-http-service-info   = module.services.ethtruism-http-service-info
  howwastoday-namespace-name    = module.services.howwastoday-namespace-name
  howwastoday-http-service-info = module.services.howwastoday-http-service-info
  providers = {
    google  = google
    kubectl = kubectl
  }

  # Maybe necessary to avoid incorrect ordering caused by dependency on module.cluster.cluster,
  # passing through data.google_container_cluster.cluster indirectly.
  # Without, some cases of attempts by terraform destroy to destroy things -after- the cluster were observed.
  depends_on = [module.cluster]
}