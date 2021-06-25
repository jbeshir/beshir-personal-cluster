resource "kubernetes_config_map" "kubeip_config" {
  metadata {
    name      = "kubeip-config"
    namespace = "kube-system"

    labels = {
      app = "kubeip"
    }
  }

  data = {
    KUBEIP_ADDITIONALNODEPOOLS = ""

    KUBEIP_ALLNODEPOOLS = "false"

    KUBEIP_FORCEASSIGNMENT = "true"

    KUBEIP_LABELKEY = "kubeip"

    KUBEIP_LABELVALUE = "static-ingress"

    KUBEIP_NODEPOOL = "ingress-pool"

    KUBEIP_SELF_NODEPOOL = "web-pool"

    KUBEIP_TICKER = "5"
  }
  depends_on = [var.cluster-name]
}

resource "kubernetes_deployment" "kubeip" {
  metadata {
    name      = "kubeip"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kubeip"
      }
    }

    template {
      metadata {
        labels = {
          app = "kubeip"
        }
      }

      spec {
        volume {
          name = "google-cloud-key"

          secret {
            secret_name = "kubeip-key"
          }
        }

        container {
          name  = "kubeip"
          image = "doitintl/kubeip:latest"

          env {
            name = "KUBEIP_LABELKEY"

            value_from {
              config_map_key_ref {
                name = "kubeip-config"
                key  = "KUBEIP_LABELKEY"
              }
            }
          }

          env {
            name = "KUBEIP_LABELVALUE"

            value_from {
              config_map_key_ref {
                name = "kubeip-config"
                key  = "KUBEIP_LABELVALUE"
              }
            }
          }

          env {
            name = "KUBEIP_NODEPOOL"

            value_from {
              config_map_key_ref {
                name = "kubeip-config"
                key  = "KUBEIP_NODEPOOL"
              }
            }
          }

          env {
            name = "KUBEIP_FORCEASSIGNMENT"

            value_from {
              config_map_key_ref {
                name = "kubeip-config"
                key  = "KUBEIP_FORCEASSIGNMENT"
              }
            }
          }

          env {
            name = "KUBEIP_ADDITIONALNODEPOOLS"

            value_from {
              config_map_key_ref {
                name = "kubeip-config"
                key  = "KUBEIP_ADDITIONALNODEPOOLS"
              }
            }
          }

          env {
            name = "KUBEIP_TICKER"

            value_from {
              config_map_key_ref {
                name = "kubeip-config"
                key  = "KUBEIP_TICKER"
              }
            }
          }

          env {
            name = "KUBEIP_ALLNODEPOOLS"

            value_from {
              config_map_key_ref {
                name = "kubeip-config"
                key  = "KUBEIP_ALLNODEPOOLS"
              }
            }
          }

          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/var/secrets/google/kubeip-key.json"
          }

          volume_mount {
            name       = "google-cloud-key"
            mount_path = "/var/secrets/google"
          }

          image_pull_policy = "Always"
        }

        restart_policy = "Always"

        node_selector = {
          "cloud.google.com/gke-nodepool" = "web-pool"
        }

        service_account_name = "main-kubeip-serviceaccount"
        priority_class_name  = "system-cluster-critical"
      }
    }
  }
  depends_on = [kubernetes_secret.kubeip_key]
}

resource "kubernetes_service_account" "kubeip_serviceaccount" {
  metadata {
    name      = "main-kubeip-serviceaccount"
    namespace = "kube-system"
  }
  depends_on = [var.cluster-name]
}

resource "kubernetes_cluster_role" "kubeip_serviceaccount" {
  metadata {
    name = "main-kubeip-serviceaccount"
  }

  rule {
    verbs      = ["get", "list", "watch", "patch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods"]
  }
  depends_on = [var.cluster-name]
}

resource "kubernetes_cluster_role_binding" "kubeip_serviceaccount" {
  metadata {
    name = "main-kubeip-serviceaccount"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "main-kubeip-serviceaccount"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "main-kubeip-serviceaccount"
  }
  depends_on = [var.cluster-name]
}

resource "kubernetes_secret" "kubeip_key" {
  metadata {
    name      = "kubeip-key"
    namespace = "kube-system"
  }

  data = {
    "kubeip-key.json" = var.kubeipserviceaccountprivatekey
  }

  type = "kubernetes.io/generic"
  depends_on = [var.cluster-name]
}