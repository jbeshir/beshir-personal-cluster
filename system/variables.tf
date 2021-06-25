variable "kubeipserviceaccountprivatekey" {
  type = string
}

# Used to introduce a dependency on the cluster.
variable "cluster-name" {
  type = string
}