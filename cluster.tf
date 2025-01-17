locals {
  cluster_name = "main-cluster"
  region       = "us-central1"
  zone         = "${local.region}-a"
}

module "cluster" {

  project                             = var.project
  source                              = "./gke"
  region                              = local.region
  location                            = local.zone
  cluster_name                        = local.cluster_name
  cluster_range_name                  = "${local.cluster_name}-pods"
  services_range_name                 = "${local.cluster_name}-services"
  node_version = "1.20.6-gke.1000"
  daily_maintenance_window_start_time = "03:00"
  subnet_cidr_range                   = "10.0.0.0/16" # 10.0.0.0 -> 10.0.255.255
  master_ipv4_cidr_block              = "10.1.0.0/28" # 10.1.0.0 -> 10.1.0.15
  cluster_range_cidr                  = "10.2.0.0/16" # 10.2.0.0 -> 10.2.255.255
  services_range_cidr                 = "10.3.0.0/16" # 10.3.0.0 -> 10.3.255.255
  nat_ip_allocate_option              = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "LIST_OF_SUBNETWORKS"
  source_ip_ranges_to_nat             = ["ALL_IP_RANGES"]
  nat_log_filter                      = "ERRORS_ONLY"
  logging_service                     = "none" # Costs 200MB per node. Would want to be running bigger nodes.
  monitoring_service                  = "monitoring.googleapis.com/kubernetes"

  node_pools = {
    ingress-pool = {
      machine_type       = "e2-micro"
      initial_node_count = 1
      min_node_count     = 1
      max_node_count     = 1
      preemptible        = false
      auto_repair        = true
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS"
      service_account    = "main-cluster-serviceaccount@${var.project}.iam.gserviceaccount.com"
      version = "1.20.6-gke.1000"
    }
    web-pool = {
      machine_type       = "e2-micro"
      initial_node_count = 2
      min_node_count     = 2  # At least two so when a preemptible node gets killed, we avoid disruption.
      max_node_count     = 2
      preemptible        = true
      auto_repair        = true
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS"
      service_account    = "main-cluster-serviceaccount@${var.project}.iam.gserviceaccount.com"
      version = "1.20.6-gke.1000"
    }
  }

  node_pools_taints = {
    ingress-pool = [
      {
        key    = "ingress-pool"
        value  = true
        effect = "NO_EXECUTE"
      }
    ]
    web-pool = []
  }

  node_pools_tags = {
    ingress-pool = [
      "ingress-pool"
    ]
    web-pool = [
      "web-pool"
    ]
  }

  node_pools_oauth_scopes = {
    custom-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
