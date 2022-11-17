
provider "google" {
  project     = var.project_id
  region      = var.region
}

########################################################
######## DSF Service Account and Permissions ###########
########################################################

# resource "google_service_account" "dsf_service_account" {
#   account_id   = var.service_account_id
#   display_name = var.service_account_name
#   project      = var.project_id
#   description  = "DSF Service Account"
# }

data "google_service_account" "service_account" {
  account_id = var.service_account_id
}

########################################################
################ DSF Instance Configs ##################
########################################################

resource "google_compute_address" "static" {
  name    = "ipv4-address"
}

data "google_compute_subnetwork" "dsf-subnetwork" {
  self_link    = var.subnetwork
  region       = var.region
}

# https://registry.terraform.io/modules/terraform-google-modules/vm/google/latest/submodules/instance_template
module "instance_template" {
  name_prefix     = var.name
  source          = "terraform-google-modules/vm/google//modules/instance_template"
  project_id      = var.project_id
  subnetwork      = data.google_compute_subnetwork.dsf-subnetwork.self_link
  service_account = {
    email = data.google_service_account.service_account.email
    # https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
    scopes = [
      "storage-ro",
      "cloud-platform"
    ]
  }
  disk_size_gb = var.boot_disk_size
  disk_type = var.disk_type
  # https://cloud.google.com/compute/docs/images/os-details
  additional_disks = [{
    disk_name    = "${var.name}-data-disk"
    device_name  = "${var.name}-data-device"
    auto_delete  = true
    boot         = false
    disk_size_gb = var.data_disk_size
    disk_type    = var.disk_type
    disk_labels  = {"name":"${var.name}-data-disk"}
  }]
  startup_script  = var.startup_script
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.gcp_ssh_pub_key_path)}"
  }
}

# https://registry.terraform.io/modules/terraform-google-modules/vm/google/latest/submodules/compute_instance?tab=inputs
module "compute_instance" {
  source              = "terraform-google-modules/vm/google//modules/compute_instance"
  zone                = var.zone
  subnetwork          = var.subnetwork
  num_instances       = 1
  hostname            = "${var.name}-imperva-dsf-hub"
  instance_template   = module.instance_template.self_link
  deletion_protection = false
  access_config = [{
    nat_ip = google_compute_address.static.address
    network_tier = "PREMIUM" # PREMIUM, FIXED_STANDARD or STANDARD
  }]
}

########################################################
################# DSF Firewall Rules ###################
########################################################


# resource "google_app_engine_application" "app" {
#   project     = var.project_id
#   location_id = var.region
# }

# resource "google_app_engine_firewall_rule" "rule" {
#   project      = var.project_id
#   priority     = 1000
#   action       = "ALLOW"
#   source_range = "*"
# }
