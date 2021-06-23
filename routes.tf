module "routes" {
  source = "./routes"
  ingress-routes-crd-version = module.crds.ingressroutescrdversion
  project = var.project
  providers = {
    google = google
    kubectl = kubectl
  }
}