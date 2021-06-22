resource "google_project_iam_custom_role" "main_cluster" {
  role_id = "main_cluster"
  title   = "main-cluster Role"

  project    = var.project
  depends_on = [google_project_service.iam]

  permissions = [
    "compute.addresses.list",
    "compute.instances.addAccessConfig",
    "compute.instances.deleteAccessConfig",
    "compute.instances.get",
    "compute.instances.list",
    "compute.projects.get",
    "container.clusters.get",
    "container.clusters.list",
    "resourcemanager.projects.get",
    "compute.networks.useExternalIp",
    "compute.subnetworks.useExternalIp",
    "compute.addresses.use",
    "resourcemanager.projects.get",
    "storage.objects.get",
    "storage.objects.list",
  ]
}

# cluster service account
resource "google_service_account" "main_cluster" {

  account_id = "main-cluster-serviceaccount"
  project    = var.project
  depends_on = [google_project_iam_custom_role.main_cluster]
}

resource "google_project_iam_member" "iam_member_main_cluster" {

  role       = "projects/${var.project}/roles/main_cluster"
  project    = var.project
  member     = "serviceAccount:main-cluster-serviceaccount@${var.project}.iam.gserviceaccount.com"
  depends_on = [google_service_account.main_cluster]
}

resource "google_project_iam_custom_role" "kubeip" {
  role_id = "main_cluster_kubeip"
  title   = "main-cluster-kubeip Role"

  project    = var.project
  depends_on = [google_project_service.iam]


  permissions = [
    "compute.addresses.list",
    "compute.instances.addAccessConfig",
    "compute.instances.deleteAccessConfig",
    "compute.instances.get",
    "compute.instances.list",
    "compute.projects.get",
    "container.clusters.get",
    "container.clusters.list",
    "resourcemanager.projects.get",
    "compute.networks.useExternalIp",
    "compute.subnetworks.useExternalIp",
    "compute.addresses.use",
  ]
}

# kubeip service account
resource "google_service_account" "kubeip" {
  account_id = "main-kubeip-serviceaccount"
  project    = var.project
  depends_on = [google_project_iam_custom_role.kubeip]
}

resource "google_project_iam_member" "iam_member_kubeip" {

  role       = "projects/${var.project}/roles/main_cluster_kubeip"
  project    = var.project
  member     = "serviceAccount:main-kubeip-serviceaccount@${var.project}.iam.gserviceaccount.com"
  depends_on = [google_service_account.kubeip]
}
