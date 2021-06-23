data "google_storage_bucket_object_content" "howwastoday-io-tls-cert" {
  name       = "howwastoday.io/tls.crt"
  bucket     = var.persistent-secrets-bucket-name
  depends_on = [var.persistent-secrets-bucket-contents]
}

data "google_storage_bucket_object_content" "howwastoday-io-tls-key" {
  name       = "howwastoday.io/tls.key"
  bucket     = var.persistent-secrets-bucket-name
  depends_on = [var.persistent-secrets-bucket-contents]
}

resource "kubernetes_secret" "howwastoday-io-tls-secret" {
  type = "kubernetes.io/tls"
  metadata {
    name      = "howwastoday-io-tls-secret"
    namespace = "howwastoday"
  }
  data = {
    "tls.crt" = data.google_storage_bucket_object_content.howwastoday-io-tls-cert.content
    "tls.key" = data.google_storage_bucket_object_content.howwastoday-io-tls-key.content
  }
}

resource "kubectl_manifest" "howwastoday-ingressroute-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: howwastoday-ingress-${var.ingress-routes-crd-version}
  namespace: howwastoday
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`backend.howwastoday.io`)
      kind: Rule
      services:
        - name: howwastoday-http
          port: 30830
YAML
}

resource "kubectl_manifest" "howwastoday-tls-ingressroute-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: howwastoday-tls-ingress-${var.ingress-routes-crd-version}
  namespace: howwastoday
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`backend.howwastoday.io`)
      kind: Rule
      services:
        - name: howwastoday-http
          port: 30830
  tls:
    secretName: howwastoday-io-tls-secret
YAML
}