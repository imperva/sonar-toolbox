
variable "service_account_name" {
  type = string
  description = "GCP service account name."
  default = "OCTO DSF Service Account"
}

variable "service_account_id" {
  type = string
  description = "GCP service account ID."
  default = "octo-dsf-service-account"
}

variable "region" {
  type = string
  description = "Region to deploy dsf in."
}

variable "project_id" {
  type = string
  description = "ID of the project in GCP." # octo
}

variable "zone" {
  type = string
  description = "Region to deploy dsf in."
  default = "us-central1-a"
}

variable "name" {
  type = string
  default = "dev-ba-imperva-dsf-hub"
}

variable "subnetwork" {
  type = string
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  default = "https://www.googleapis.com/compute/v1/projects/octo-365915/regions/us-central1/subnetworks/default"
}

variable "boot_disk_size" {
  validation {
    condition     = var.boot_disk_size >= 30
    error_message = "DSF boot disk size in GB."
  }
  default = 30
}

variable "data_disk_size" {
  validation {
    condition     = var.data_disk_size >= 100
    error_message = "DSF data disk size in GB."
  }
  default = 100
}

variable "disk_type" {
  type = string
  description = "Boot disk type, can be either pd-ssd, local-ssd, or pd-standard"
  default = "pd-standard"
}

variable "ssh_user" {
  type = string
  default = "dsfadmin"
}

variable "gcp_ssh_pub_key_path" {
  type = string
  description = "Path to the gcp ssh public key used to access the DSF VM instances."
  default = "~/.ssh/gcp_rsa.pub"
}

variable "gcp_bucket_name" {
  type = string
  description = "Name of the GCP storage bucket where the dsf install file resides." 
}

variable "dsf_version" { 
  type = string
  description = "Dsf version." 
}

variable "dsf_install_tarball_path" { 
  type = string
  description = "Path to dsf install tar package file in the gcp stroage bucket."
}

variable firewall_ingress_cidrs {
  type = list
  description = "List of allowed ingress cidr patterns for the DSF hub instance"
}

variable "admin_password" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.admin_password) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

variable "secadmin_password" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.secadmin_password) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

variable "sonarg_pasword" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.sonarg_pasword) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

variable "sonargd_pasword" {
  type = string
  sensitive = true
  description = "Admin password"
  validation {
    condition = length(var.sonargd_pasword) > 8
    error_message = "Admin password must be at least 8 characters."
  }
}

######################## Additional (optional) parameters ########################
# Use this param to specify any additional parameters for the initial setup, example syntax below
# { default = "--jsonar-logdir=\"/path/to/log/dir\" --smtp-ssl --ignore-system-warnings" }
# https://sonargdocs.jsonar.com/4.5/en/sonar-setup.html#noninteractive-setup
variable "additional_parameters" { default = "" }