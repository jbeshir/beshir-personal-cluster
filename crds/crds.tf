output "ingressroutescrdversion" {
  value = "ingressroutes-crd-1" # Keep updated with resource name. Hack so that resources recreate.
}


resource "kubectl_manifest" "ingressroutes-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: ingressroutes.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: IngressRoute
    plural: ingressroutes
    singular: ingressroute
  scope: Namespaced
YAML
}

resource "kubectl_manifest" "ingressroutetcps-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: ingressroutetcps.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: IngressRouteTCP
    plural: ingressroutetcps
    singular: ingressroutetcp
  scope: Namespaced
YAML
}

resource "kubectl_manifest" "ingressrouteudps-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: ingressrouteudps.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: IngressRouteUDP
    plural: ingressrouteudps
    singular: ingressrouteudp
  scope: Namespaced
YAML
}

resource "kubectl_manifest" "middlewares-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: middlewares.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: Middleware
    plural: middlewares
    singular: middleware
  scope: Namespaced
YAML
}

resource "kubectl_manifest" "serverstransports-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: serverstransports.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: ServersTransport
    plural: serverstransports
    singular: serverstransport
  scope: Namespaced
YAML
}

resource "kubectl_manifest" "tlsoptions-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: tlsoptions.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: TLSOption
    plural: tlsoptions
    singular: tlsoption
  scope: Namespaced
YAML
}

resource "kubectl_manifest" "tlsstores-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: tlsstores.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: TLSStore
    plural: tlsstores
    singular: tlsstore
  scope: Namespaced
YAML
}

resource "kubectl_manifest" "traefikservices-crd-1" { # Increment on all changes. Hack so that changes recreate.
  yaml_body = <<YAML
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: traefikservices.traefik.containo.us

spec:
  group: traefik.containo.us
  version: v1alpha1
  names:
    kind: TraefikService
    plural: traefikservices
    singular: traefikservice
  scope: Namespaced
YAML
}