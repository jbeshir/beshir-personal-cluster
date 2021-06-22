resource "kubernetes_manifest" "howwastoday-ingressroute" {
  provider = kubernetes-alpha
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind = "IngressRoute"
    metadata = {
      name = "howwastoday-ingress"
      namespace = "howwastoday"
    }
    spec = {
      entryPoints = ["web"]
      routes = [{
        match = "Host(`backend.howwastoday.io`)"
        kind = "Rule"
        services = [{
          name = "howwastoday-http"
          namespace = "howwastoday"
          port = 30830
        }]
      }]
    }
  }
}
resource "kubernetes_manifest" "howwastoday-tls-ingressroute" {
  provider = kubernetes-alpha
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind = "IngressRoute"
    metadata = {
      name = "howwastoday-tls-ingress"
      namespace = "howwastoday"
    }
    spec = {
      entryPoints = [
        "websecure"
      ]
      routes = [{
        match = "Host(`backend.howwastoday.io`)"
        kind = "Rule"
        services = [{
          name = "howwastoday-http"
          namespace = "howwastoday"
          port = 30830
        }]
      }]
      tls = {
        secretName = "howwastoday-cf-certificate"
      }
    }
  }
}