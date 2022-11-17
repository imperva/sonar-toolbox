terraform {
  required_version = ">= 0.12.8"
}

provider "google" {
  project     = var.project_id
  region      = var.region
}

data "google_service_account" "service_account" {
  account_id = var.service_account_id
}

locals {
  # Uncomment this section to use randomly generated passwords instead of the pre-defined passwords listedbelow
  # dsf_passwords_obj  = {
  #   admin_password = random_password.admin_password.result
  #   secadmin_password = random_password.secadmin_password.result
  #   sonarg_pasword = random_password.sonarg_pasword.result
  #   sonargd_pasword = random_password.sonargd_pasword.result
  # }
  dsf_passwords_obj  = {
    admin_password = "Imperva123#"
    secadmin_password = "Imperva123#"
    sonarg_pasword = "Imperva123#"
    sonargd_pasword = "Imperva123#"
  }
}

resource "google_secret_manager_secret" "dsf_passwords" {
  secret_id = "${var.environment}_dsf_passwords"
  labels = { type = "dsf_passwords" }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "dsf_passwords_ver" {
  secret = google_secret_manager_secret.dsf_passwords.id
  secret_data = jsonencode(local.dsf_passwords_obj)
}


resource "tls_private_key" "dsf_hub_ssh_federation_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_secret_manager_secret" "dsf_hub_federation_public_key" {
  secret_id = "${var.environment}_dsf_hub_federation_public_key"
  labels = { type = "dsf-hub-public-key" }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "dsf_hub_federation_public_key_ver" {
  secret = google_secret_manager_secret.dsf_hub_federation_public_key.id
  secret_data = resource.tls_private_key.dsf_hub_ssh_federation_key.public_key_openssh
}

resource "google_secret_manager_secret" "dsf_hub_federation_private_key" {
  secret_id = "${var.environment}_dsf_hub_federation_private_key"
  labels = { type = "dsf-hub-private-key" }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "dsf_hub_federation_private_key_ver" {
  secret = google_secret_manager_secret.dsf_hub_federation_private_key.id
  secret_data = resource.tls_private_key.dsf_hub_ssh_federation_key.private_key_pem
}


resource "tls_private_key" "dsf_gateway_ssh_federation_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_secret_manager_secret" "dsf_gateway_federation_public_key" {
  secret_id = "${var.environment}_dsf_gateway_federation_public_key"
  labels = { type = "dsf-gateway-public-key" }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "dsf_gateway_federation_public_key_ver" {
  secret = google_secret_manager_secret.dsf_gateway_federation_public_key.id
  secret_data = resource.tls_private_key.dsf_gateway_ssh_federation_key.public_key_openssh
}


resource "google_secret_manager_secret" "dsf_gateway_federation_private_key" {
  secret_id = "${var.environment}_dsf_gateway_federation_private_key"
  labels = { type = "dsf-gateway-private-key" }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "dsf_gateway_federation_private_key_ver" {
  secret = google_secret_manager_secret.dsf_gateway_federation_private_key.id
  secret_data = resource.tls_private_key.dsf_gateway_ssh_federation_key.private_key_pem
}

