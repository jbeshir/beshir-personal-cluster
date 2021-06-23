module "kt_test" {
  source = "../../.."
  project = local.project
  persistent-secrets-bucket-contents = module.persistent-replacement.persistent-secrets-bucket-contents
}