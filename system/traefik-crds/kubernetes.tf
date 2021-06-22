provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "gke-personal-main"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
  config_context = "gke-personal-main"
}