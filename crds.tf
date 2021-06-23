module "crds" {
  source     = "./crds"
  depends_on = [module.cluster]
  providers = {
    kubectl = kubectl
  }
}