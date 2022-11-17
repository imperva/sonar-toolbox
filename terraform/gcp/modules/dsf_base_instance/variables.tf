variable "service_account_id" {
  type = string
  description = "GCP service account ID."
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
}

variable "name" {
  type = string
  description = "Name of the deployment."
}

variable "subnetwork" {
  type = string
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
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
  description = "Name of the ssh user."
}

variable "gcp_ssh_pub_key_path" {
  type = string
  description = "Path to the gcp ssh local public key used to access the DSF VM instances."
}

variable "gcp_bucket_name" {
  type = string
  description = "Name of the storage bucket."
}

variable firewall_ingress_cidrs {
  type = list
  description = "List of allowed ingress cidr patterns for the DSF hub instance"
}

variable startup_script {
  type = string
  description = "Startup script for instance."
}
