#################################
# Hub cloudinit script (AKA userdata)
#################################

resource "random_uuid" "uuid" {}

data "template_file" "hub_cloudinit" {
  template = file("${path.module}/hub_cloudinit.tpl")
  vars = {
    name                                = var.name
    admin_password                      = var.admin_password
    secadmin_password                   = var.secadmin_password
    sonarg_pasword                      = var.sonarg_pasword
    sonargd_pasword                     = var.sonargd_pasword
    gcp_bucket_name                     = var.gcp_bucket_name 
    dsf_version                         = var.dsf_version
    dsf_install_tarball_path            = var.dsf_install_tarball_path
    additional_parameters               = var.additional_parameters
    uuid                                = random_uuid.uuid.result
    # dsf_hub_public_key_name             = var.dsf_hub_public_key_name
    # dsf_hub_private_key_name            = var.dsf_hub_private_key_name
    # dsf_gateway_public_authorized_keys  = join(";|;", var.dsf_gateway_public_authorized_keys)
  }
}

#################################
# Actual Hub instance
#################################

module "hub_instance" {
  source                         = "../../modules/dsf_base_instance"
  service_account_id             = var.service_account_id
  region                         = var.region
  project_id                     = var.project_id
  zone                           = var.zone
  name                           = var.name
  subnetwork                     = var.subnetwork
  boot_disk_size                 = var.boot_disk_size
  data_disk_size                 = var.data_disk_size
  disk_type                      = var.disk_type
  ssh_user                       = var.ssh_user
  gcp_ssh_pub_key_path           = var.gcp_ssh_pub_key_path
  gcp_bucket_name                = var.gcp_bucket_name
  firewall_ingress_cidrs         = var.firewall_ingress_cidrs
  startup_script                 = data.template_file.hub_cloudinit.rendered
}