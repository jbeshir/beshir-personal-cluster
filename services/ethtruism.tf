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
    replicas = 1
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