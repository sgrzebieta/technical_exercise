locals {
  mongo_sa = {
    email  = google_service_account.mongodb.email
    scopes = []
  }
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "default" {
  name    = "compute-gw-group1"
  project = var.project_id
  network = module.vpc.network_name
  region  = var.region

  depends_on = [
    module.vpc
  ]
}

module "cloud_nat" {
  source = "terraform-google-modules/cloud-nat/google"

  router     = google_compute_router.default.name
  project_id = var.project_id
  region     = var.region
  name       = "compute-cloud-nat-group1"
}

resource "google_service_account" "mongodb" {
  account_id   = "mongodb"
  project      = var.project_id
  display_name = "mongodb-sa"
  description  = "MongoDB Service Account"
}

data "google_compute_image" "mongodb" {
  name    = "mongo"
  project = var.project_id
}

resource "google_storage_bucket" "mongo_backup" {
  name     = "mongodb-backups-16279"
  project  = var.project_id
  location = var.region
}

resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.mongo_backup.name
  role   = "OWNER"
  entity = "allUsers"
}

module "mongodb_template" {
  source = "terraform-google-modules/vm/google//modules/instance_template"

  project_id         = var.project_id
  subnetwork_project = var.project_id
  region             = var.region
  network            = module.vpc.network_self_link
  subnetwork         = "subnet-02"
  service_account    = local.mongo_sa
  name_prefix        = "mongodb"
  source_image       = data.google_compute_image.mongodb.self_link
  startup_script     = templatefile("${path.module}/scripts/backup.sh.tpl", { bucket_name = "google_storage_bucket.mongo_backup.url" })

  depends_on = [
    module.vpc
  ]
}

module "mongodb_mig" {
  source = "terraform-google-modules/vm/google//modules/mig"

  project_id          = var.project_id
  instance_template   = module.mongodb_template.self_link
  region              = var.region
  hostname            = "mongodb"
  target_size         = 1
  autoscaling_enabled = false
  min_replicas        = 1
  health_check_name   = "mongodb-http-hc"

  health_check = {
    type                = "http"
    initial_delay_sec   = 120
    check_interval_sec  = 5
    healthy_threshold   = 2
    timeout_sec         = 5
    unhealthy_threshold = 2
    response            = ""
    proxy_header        = "NONE"
    port                = 27017
    request             = ""
    request_path        = "/"
    host                = "localhost"
    enable_logging      = false
  }

  named_ports = [
    {
      name = "mongdb",
      port = "27017"
    }
  ]
}

resource "google_compute_firewall" "ssh" {
  project     = var.project_id
  name        = "ssh"
  network     = module.vpc.network_name
  description = "firewall rule to allow ssh"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "mongdb" {
  project     = var.project_id
  name        = "mongdb"
  network     = module.vpc.network_name
  description = "firewall rule to allow GKE access MongoDB"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_ranges = [
    "10.10.0.0/17",
    "10.30.0.0/18",
    "10.40.0.0/18",
  ]
}