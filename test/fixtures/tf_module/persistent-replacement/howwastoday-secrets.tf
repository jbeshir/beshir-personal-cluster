# TLS certificate for howwastoday.io and wildcard subdomains.
# Expected to be a Cloudflare Origin Server certificate, for long expiry.
resource "google_storage_bucket_object" "howwastoday-io-tls-cert" {
  name    = "howwastoday.io/tls.crt"
  content = tls_self_signed_cert.howwastoday-io-self-signed-cert.cert_pem
  bucket  = module.base.persistent-secrets-bucket-name
}

resource "google_storage_bucket_object" "howwastoday-io-tls-privatekey" {
  name    = "howwastoday.io/tls.key"
  content = tls_private_key.howwastoday-io-private-key.private_key_pem
  bucket  = module.base.persistent-secrets-bucket-name
}

resource "tls_self_signed_cert" "howwastoday-io-self-signed-cert" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.howwastoday-io-private-key.private_key_pem

  subject {
    common_name  = "howwastoday.io"
    organization = "Beshir.org"
  }

  dns_names = [
    "*.howwastoday.io",
    "howwastoday.io"
  ]

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "howwastoday-io-private-key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}