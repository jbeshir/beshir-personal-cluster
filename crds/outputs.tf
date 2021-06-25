# Allows establishing dependencies on these resources.
output "crds" {
  value = [
    kubectl_manifest.ingressroutes-crd-1,
    kubectl_manifest.ingressroutetcps-crd-1,
    kubectl_manifest.ingressrouteudps-crd-1,
    kubectl_manifest.middlewares-crd-1,
    kubectl_manifest.serverstransports-crd-1,
    kubectl_manifest.tlsoptions-crd-1,
    kubectl_manifest.tlsstores-crd-1,
    kubectl_manifest.traefikservices-crd-1
  ]
}