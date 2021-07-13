resource "kubernetes_namespace" "ethtruism" {
  metadata {
    name = "ethtruism"
  }
  depends_on = [var.cluster-name]
}

resource "kubernetes_deployment" "ethtruism-backend" {
  metadata {
    name      = "ethtruism-backend"
    namespace = kubernetes_namespace.ethtruism.metadata.0.name
  }
  spec {
    replicas = 2  # At least two so when a node gets terminated, we can avoid disruption.
    strategy {
      # Since our node pool is very tight on space, we can't rely on surging pods to perform updates.
      type = "RollingUpdate"
      rolling_update {
        max_surge = 0
        max_unavailable = 1
      }
    }

    selector {
      match_labels = {
        app = "ethtruism"
      }
    }
    template {
      metadata {
        labels = {
          app = "ethtruism"
        }
      }
      spec {
        affinity {
          # Run different replicas on different nodes, so we have resilience against node shutdown.
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = [
                    "ethtruism"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
        container {
          image = "gcr.io/${var.project}/ethtruism:latest"
          name  = "ethtruism"
          port {
            name           = "http"
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ethtruism-http" {
  metadata {
    name      = "ethtruism-http"
    namespace = kubernetes_namespace.ethtruism.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.ethtruism-backend.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 30840
      target_port = 8090

    }
  }
}