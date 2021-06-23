resource "null_resource" "create_file_2" {
  provisioner "local-exec" {
    command = "echo ${module.cluster.kubeipserviceaccountid} > foobar"
  }
}