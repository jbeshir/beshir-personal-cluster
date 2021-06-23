module "services" {
	source = "./services"
	project = var.project
	depends_on = [module.cluster]
	providers = {
		kubernetes = kubernetes
	}
}