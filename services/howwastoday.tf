resource "kubernetes_namespace" "howwastoday" {
  metadata {
    name = "howwastoday"
  }
}

resource "kubernetes_deployment" "howwastoday-backend" {
  metadata {
    name      = "howwastoday-backend"
    namespace = kubernetes_namespace.howwastoday.metadata.0.name
  }
  spec {
    replicas = 1
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