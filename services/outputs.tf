output "ethtruism-namespace-name" {
  value = kubernetes_namespace.ethtruism.metadata.0.name
}

output "ethtruism-http-service-info" {
  value = {
    name = kubernetes_service.ethtruism-http.metadata.0.name
    port = kubernetes_service.ethtruism-http.spec.0.port.0.port
  }
}

output "howwastoday-namespace-name" {
  value = kubernetes_namespace.howwastoday.metadata.0.name
}

output "howwastoday-http-service-info" {
  value = {
    name = kubernetes_service.howwastoday-http.metadata.0.name
    port = kubernetes_service.howwastoday-http.spec.0.port.0.port
  }
}