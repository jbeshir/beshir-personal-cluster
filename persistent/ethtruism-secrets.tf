# TLS certificate for howwastoday.io and wildcard subdomains.
# Expected to be a Cloudflare Origin Server certificate, for long expiry.
resource "google_storage_bucket_object" "ethtruism-com-tls-cert" {
  name   = "ethtruism.com/tls.crt"
  source = "./secrets/ethtruism.com.crt"
  bucket = module.base.persistent-secrets-bucket-name
}

resource "google_storage_bucket_object" "ethtruism-com-tls-privatekey" {
  name   = "ethtruism.com/tls.key"
  source = "./secrets/ethtruism.com.key"
  bucket = module.base.persistent-secrets-bucket-name
}