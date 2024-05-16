data "google_client_config" "default" {}

data "google_compute_subnetwork" "subnetwork" {
  name    = "subnet-01"
  project = var.project_id
  region  = var.region

  depends_on = [
    module.vpc
  ]
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google"

  project_id               = var.project_id
  name                     = "wiz-tc"
  region                   = var.region
  zones                    = var.zones
  network                  = module.vpc.network_name
  datapath_provider        = "ADVANCED_DATAPATH"
  subnetwork               = "subnet-01"
  ip_range_pods            = "subnet-01-secondary-01"
  ip_range_services        = "subnet-01-secondary-02"
  remove_default_node_pool = true
  http_load_balancing      = true
  deletion_protection      = false

  node_pools = [
    {
      name = "wiz-tc-01"
    },
  ]

  depends_on = [
    module.vpc
  ]
}

resource "google_compute_firewall" "gke" {
  project     = var.project_id
  name        = "gke"
  network     = module.vpc.network_name
  description = "firewall rule to allow ssh"

  allow {
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${module.gke.service_account}"

  depends_on = [
    module.gke
  ]
}

