module "routes" {
  source                             = "./routes"
  ingress-routes-crd-version         = module.crds.ingressroutescrdversion
  persistent-secrets-bucket-name     = "${var.project}-${data.google_project.project.number}-persistent-secrets"
  persistent-secrets-bucket-contents = var.persistent-secrets-bucket-contents # Used to introduce a dependency for tests.
  providers = {
    google  = google
    kubectl = kubectl
  }
  ethtruism-namespace-name      = module.services.ethtruism-namespace-name
  ethtruism-http-service-info   = module.services.ethtruism-http-service-info
  howwastoday-namespace-name    = module.services.howwastoday-namespace-name
  howwastoday-http-service-info = module.services.howwastoday-http-service-info
}