output "persistent-secrets-bucket-name" {
  value = module.base.persistent-secrets-bucket-name
}

output "persistent-secrets-bucket-contents" {
  value = [
    google_storage_bucket_object.howwastoday-io-tls-cert,
    google_storage_bucket_object.howwastoday-io-tls-privatekey,
    google_storage_bucket_object.ethtruism-com-tls-cert,
    google_storage_bucket_object.ethtruism-com-tls-privatekey
  ]
}