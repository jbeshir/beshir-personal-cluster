# Sleep until the ingress IP is successfully assigned by kubeip to traefik.
# Prevents us from finishing the apply until the setup is -really- finished.
resource "null_resource" "wait-for-ingress-ip" {
  provisioner "local-exec" {
    command = "until curl ${module.persistent-replacement.ingress-ip}; do sleep 10; done"
  }
  depends_on = [module.kt_test]
}