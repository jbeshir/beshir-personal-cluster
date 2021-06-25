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
    namespace = var.howwastoday-namespace-name
  }

  # Sometimes https://github.com/hashicorp/terraform-provider-kubernetes/issues/782 seems to happen,
  # if it's a terraform apply on an existing state, even if data is unchanged.
  # A rerun of terraform apply seems to fix it.
  # If this becomes an ongoing problem, ignore_changes = all might fix (at the cost of no cert updates!)
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
  namespace: ${var.howwastoday-namespace-name}
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`backend.howwastoday.io`)
      kind: Rule
      services:
        - name: ${var.howwastoday-http-service-info.name}
          port: ${var.howwastoday-http-service-info.port}
YAML
  depends_on = [var.crds]
}

resource "kubectl_manifest" "howwastoday-tls-ingressroute-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: howwastoday-tls-ingress-${var.ingress-routes-crd-version}
  namespace: ${var.howwastoday-namespace-name}
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`backend.howwastoday.io`)
      kind: Rule
      services:
        - name: ${var.howwastoday-http-service-info.name}
          port: ${var.howwastoday-http-service-info.port}
  tls:
    secretName: howwastoday-io-tls-secret
YAML
  depends_on = [var.crds]
}