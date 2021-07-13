output "nonscaling-redis-service-info" {
  value = {
    name = kubernetes_service.nonscaling-redis.metadata.0.name
    port = kubernetes_service.nonscaling-redis.spec.0.port.0.port
  }
}