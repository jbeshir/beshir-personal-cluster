resource "google_service_account_key" "kubeip_serviceaccount_key" {
	service_account_id = module.cluster.kubeipserviceaccountid
}

module "system" {
	source = "./system"
	depends_on = [module.cluster, module.crds]
	providers = {
		kubernetes = kubernetes
	}
	kubeipserviceaccountprivatekey = base64decode(google_service_account_key.kubeip_serviceaccount_key.private_key)
}