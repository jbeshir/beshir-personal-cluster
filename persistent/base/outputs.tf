output "ingress-ip" {
  value = google_compute_address.static-ingress.address
}

output "persistent-secrets-bucket-name" {
  value = google_storage_bucket.persistent-secrets.name
}