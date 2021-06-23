# TLS certificate for howwastoday.io and wildcard subdomains.
# Expected to be a Cloudflare Origin Server certificate, for long expiry.
resource "google_storage_bucket_object" "howwastoday-io-tls-cert" {
  name   = "howwastoday.io/tls.crt"
  source = "./secrets/howwastoday.io.crt"
  bucket = module.base.persistent-secrets-bucket-name
}

resource "google_storage_bucket_object" "howwastoday-io-tls-privatekey" {
  name   = "howwastoday.io/tls.key"
  source = "./secrets/howwastoday.io.key"
  bucket = module.base.persistent-secrets-bucket-name
}