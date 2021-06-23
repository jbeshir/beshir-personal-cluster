# Defines the place where we'll put all our secrets.
# It's regional, because our cluster is regional.
resource "google_storage_bucket" "persistent-secrets" {
  name = "${var.project}-${data.google_project.project.number}-persistent-secrets"
  location = var.region
  project = var.project
  storage_class = "REGIONAL"
  uniform_bucket_level_access = true
}