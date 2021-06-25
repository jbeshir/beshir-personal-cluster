output "kubeipserviceaccountid" {
  value = google_service_account.kubeip.name
}

output "cluster-id" {
  value = google_container_cluster.k8s.id
}