resource "kubernetes_config_map" "traefik_config" {
  metadata {
    name      = "traefik-config"
    namespace = "traefik"
  }

  data = {
    CF_API_EMAIL = "your.email@goes.here"
  }
}

resource "kubernetes_deployment" "traefik_web" {
  metadata {
    name      = "traefik-web"
    namespace = "traefik"

    labels = {
      "app.kubernetes.io/name" = "traefik-web"

      "app.kubernetes.io/part-of" = "traefik-web"
    }
  }

  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "traefik-web"

        "app.kubernetes.io/part-of" = "traefik-web"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "traefik-web"

          "app.kubernetes.io/part-of" = "traefik-web"
        }
      }

      spec {
        container {
          name  = "traefik"
          image = "traefik:v2.1.9"
          args  = ["--entrypoints.web.address=:80",
            "--entrypoints.websecure.address=:443",
            "--entrypoints.ping.address=:10254",
            "--ping.entrypoint=ping",

            # This project uses Kubernetes CRDs to configure traefik.
            "--providers.kubernetescrd",

            # Trusts Cloudflare's reported origin IPs; passes the true origin IP on to the services.
            "--entrypoints.https.forwardedHeaders.trustedIPs=173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/12,172.64.0.0/13,131.0.72.0/22",

            # Enable dashboard. Can be accessed using kubectl port-forward.
            # "--api.dashboard=true",
            # "--api.insecure=true",

            # Verbose logging. Change to ERROR to disable.
            "--log.level=INFO"]

          port {
            name           = "web"
            container_port = 80
            host_port = 80
          }

          port {
            name           = "admin"
            container_port = 8080
          }

          port {
            name           = "websecure"
            container_port = 443
            host_port = 443
          }

          liveness_probe {
            http_get {
              path   = "/ping"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/ping"
              port   = "10254"
              scheme = "HTTP"
            }

            timeout_seconds   = 1
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 3
          }
        }

        node_selector = {
          "cloud.google.com/gke-nodepool" = "ingress-pool"
        }

        service_account_name = "traefik-serviceaccount"

        toleration {
          key      = "ingress-pool"
          operator = "Equal"
          value    = "true"
          effect   = "NoExecute"
        }
      }
    }
  }
}

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"

    labels = {
      name = "traefik"
    }
  }
}

resource "kubernetes_cluster_role" "traefik" {
  metadata {
    name = "traefik"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["traefik.containo.us"]
    resources  = ["middlewares"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["traefik.containo.us"]
    resources  = ["ingressroutes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["traefik.containo.us"]
    resources  = ["ingressroutetcps"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["traefik.containo.us"]
    resources  = ["ingressrouteudps"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["traefik.containo.us"]
    resources  = ["tlsoptions"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["traefik.containo.us"]
    resources  = ["tlstores"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["traefik.containo.us"]
    resources  = ["traefikservices"]
  }
}

resource "kubernetes_cluster_role_binding" "traefik" {
  metadata {
    name = "traefik"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "traefik-serviceaccount"
    namespace = "traefik"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik"
  }
}

resource "kubernetes_service_account" "traefik_serviceaccount" {
  metadata {
    name      = "traefik-serviceaccount"
    namespace = "traefik"
  }
}