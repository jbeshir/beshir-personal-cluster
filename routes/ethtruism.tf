data "google_storage_bucket_object_content" "ethtruism-com-tls-cert" {
  name       = "ethtruism.com/tls.crt"
  bucket     = var.persistent-secrets-bucket-name
  depends_on = [var.persistent-secrets-bucket-contents]
}

data "google_storage_bucket_object_content" "ethtruism-com-tls-key" {
  name       = "ethtruism.com/tls.key"
  bucket     = var.persistent-secrets-bucket-name
  depends_on = [var.persistent-secrets-bucket-contents]
}

resource "kubernetes_secret" "ethtruism-com-tls-secret" {
  type = "kubernetes.io/tls"
  metadata {
    name      = "ethtruism-com-tls-secret"
    namespace = var.ethtruism-namespace-name
  }
  data = {
    "tls.crt" = data.google_storage_bucket_object_content.ethtruism-com-tls-cert.content
    "tls.key" = data.google_storage_bucket_object_content.ethtruism-com-tls-key.content
  }
}

resource "kubectl_manifest" "ethtruism-ingressroute-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: ethtruism-ingress-${var.ingress-routes-crd-version}
  namespace: ${var.ethtruism-namespace-name}
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`ethtruism.com`) || Host(`www.ethtruism.com`)
      kind: Rule
      services:
        - name: ${var.ethtruism-http-service-info.name}
          port: ${var.ethtruism-http-service-info.port}
YAML
}

resource "kubectl_manifest" "ethtruism-tls-ingressroute-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: ethtruism-tls-ingress-${var.ingress-routes-crd-version}
  namespace: ${var.ethtruism-namespace-name}
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`ethtruism.com`) || Host(`www.ethtruism.com`)
      kind: Rule
      services:
        - name: ${var.ethtruism-http-service-info.name}
          port: ${var.ethtruism-http-service-info.port}
  tls:
    secretName: ethtruism-com-tls-secret
YAML
}