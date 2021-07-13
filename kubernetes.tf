# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {
}

# Retrieve information separately to the cluster resource in module.cluster,
# because it appears that otherwise this information can be cached in the state in an incorrect manner,
# at least if used as a parameter to a provider.
# Probably related to https://github.com/hashicorp/terraform/issues/4149
# and https://github.com/hashicorp/terraform-provider-kubernetes/issues/1028
data google_container_cluster "cluster" {
  name     = local.cluster_name
  location = local.zone

  # Don't retrieve this information until the cluster is ready.
  # May allow this to work in a single config.
  depends_on = [module.cluster.cluster-id]
}

provider "kubernetes" {
  # config_path = "~/.kube/config"

  host  = "https://${data.google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.default.access_token
  client_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].client_certificate)
  client_key = base64decode(data.google_container_cluster.cluster.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
}

provider "kubectl" {
  # config_path = "~/.kube/config"

  host  = "https://${data.google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.default.access_token
  client_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].client_certificate)
  client_key = base64decode(data.google_container_cluster.cluster.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)

  # Possibly necessary per https://github.com/gavinbunney/terraform-provider-kubectl/pull/107
  load_config_file = false
}