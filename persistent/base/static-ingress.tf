# If we don't persist the static IP,
# we can't point DNS at the cluster.
resource "google_compute_address" "static-ingress" {
  name     = "static-ingress"
  project  = var.project
  region   = var.region
  provider = google-beta

  # address labels are a beta feature
  labels = {
    kubeip = "static-ingress"
  }
}