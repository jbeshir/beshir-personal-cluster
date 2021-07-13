# Non-scaling platform services.
# These exist where the right answer to scale is to use a managed service (e.g. Memorystore for Redis)
# But I don't want to pay the bill for it, at least until I actually need it.
# Services which make use of this will require migrating off here to such a managed service at the right time.
resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
  depends_on = [var.cluster-name]
}

resource "kubernetes_deployment" "howwastoday-backend" {
  metadata {
    name      = "howwastoday-backend"
    namespace = kubernetes_namespace.howwastoday.metadata.0.name
  }
  spec {
    replicas = 1 # Not configured for scaling.
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
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          image = "marketplace.gcr.io/google/redis5"
          name  = "redis"
          port {
            name           = "redis"
            container_port = 6379
          }
        }

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

resource "kubernetes_service" "nonscaling-redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.howwastoday.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.howwastoday-backend.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 6379
      target_port = 6379
    }
  }
}