# TLS certificate for howwastoday.io and wildcard subdomains.
# Expected to be a Cloudflare Origin Server certificate, for long expiry.
resource "google_storage_bucket_object" "ethtruism-com-tls-cert" {
  name    = "ethtruism.com/tls.crt"
  content = tls_self_signed_cert.ethtruism-com-self-signed-cert.cert_pem
  bucket  = module.base.persistent-secrets-bucket-name
}

resource "google_storage_bucket_object" "ethtruism-com-tls-privatekey" {
  name    = "ethtruism.com/tls.key"
  content = tls_private_key.ethtruism-com-private-key.private_key_pem
  bucket  = module.base.persistent-secrets-bucket-name
}

resource "tls_self_signed_cert" "ethtruism-com-self-signed-cert" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.ethtruism-com-private-key.private_key_pem

  subject {
    common_name  = "ethtruism.com"
    organization = "Beshir.org"
  }

  dns_names = [
    "ethtruism.com", "*.ethtruism.com"
  ]

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "ethtruism-com-private-key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}