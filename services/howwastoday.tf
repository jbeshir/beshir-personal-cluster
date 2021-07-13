resource "kubernetes_namespace" "howwastoday" {
  metadata {
    name = "howwastoday"
  }
  depends_on = [var.cluster-name]
}

resource "kubernetes_deployment" "howwastoday-backend" {
  metadata {
    name      = "howwastoday-backend"
    namespace = kubernetes_namespace.howwastoday.metadata.0.name
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
        app = "howwastoday"
      }
    }
    template {
      metadata {
        labels = {
          app = "howwastoday"
        }
      }
      spec {
        container {
          image = "gcr.io/${var.project}/howwastoday:latest"
          name  = "howwastoday"
          port {
            name           = "http"
            container_port = 80
          }
        }

        affinity {
          # Run different replicas on different nodes, so we have resilience against node shutdown.
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = [
                    "howwastoday"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "howwastoday-http" {
  metadata {
    name      = "howwastoday-http"
    namespace = kubernetes_namespace.howwastoday.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.howwastoday-backend.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 30830
      target_port = 80
    }
  }
}