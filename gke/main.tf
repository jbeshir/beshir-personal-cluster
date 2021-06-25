resource "google_project_service" "cloudresourcemanager" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false # Otherwise we can't retrieve current state.
}

resource "google_project_service" "compute" {
  project    = var.project
  service    = "compute.googleapis.com"
  depends_on = [google_project_service.cloudresourcemanager]

  disable_dependent_services = true
  disable_on_destroy         = false # Otherwise we can't retrieve current state.
}

resource "google_project_service" "container" {
  project    = var.project
  service    = "container.googleapis.com"
  depends_on = [google_project_service.compute]

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "iam" {
  project    = var.project
  service    = "iam.googleapis.com"
  depends_on = [google_project_service.cloudresourcemanager]

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_container_cluster" "k8s" {
  provider           = google
  name               = var.cluster_name
  project            = var.project
  depends_on         = [google_project_service.container]
  location           = var.location
  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  # need to create a default node pool
  # delete this immediately
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke-network.self_link
  subnetwork = google_compute_subnetwork.gke-subnet.self_link

  private_cluster_config {
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Automatically fill out the local kubectl config.
  # This COULD be necessary (in some adjusted form, maybe store to another file?),
  # as part of some workarounds to make cluster creation and usage in a provider in the same tree behave.
  #
  # See https://github.com/hashicorp/terraform-provider-kubernetes/issues/1028
  # provisioner "local-exec" {
  #   command = "gcloud container clusters get-credentials ${var.cluster_name} --zone=${var.location} --project=${var.project}"
  # }
}
