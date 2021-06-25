output "ingress-ip" {
  value = module.base.ingress-ip
}

output "ethtruism-com-tls-cert-pem" {
  value = tls_self_signed_cert.ethtruism-com-self-signed-cert.cert_pem
}

output "howwastoday-io-tls-cert-pem" {
  value = tls_self_signed_cert.howwastoday-io-self-signed-cert.cert_pem
}

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