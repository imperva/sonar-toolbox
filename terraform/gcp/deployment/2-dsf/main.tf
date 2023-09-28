
provider "google" {
  project     = var.project_id
  region      = var.region
}

data "terraform_remote_state" "init" {
	backend = "local"
	config = {
		path = "${path.module}/../1-init/terraform.tfstate"
	}
}

data "google_secret_manager_secret_version" "dsf_passwords" {
  secret = data.terraform_remote_state.init.outputs.dsf_passwords_secret_name
}

module "sonarw" {
	source                         = "../../modules/sonarw"
	region                         = var.region
	name                           = "${var.name}-imperva-dsf-hub"
	service_account_id             = var.service_account_id
	project_id                     = var.project_id
	zone                           = var.zone
	subnetwork                     = var.subnetwork
	boot_disk_size                 = var.boot_disk_size
	data_disk_size                 = var.data_disk_size
	disk_type                      = var.disk_type
	ssh_user                       = var.ssh_user
	gcp_ssh_pub_key_path           = var.gcp_ssh_pub_key_path
	gcp_bucket_name                = var.gcp_bucket_name
	firewall_ingress_cidrs         = var.firewall_ingress_cidrs
	dsf_version                    = var.dsf_version
	dsf_install_tarball_path 	   = var.dsf_install_tarball_path
	admin_password 				   = jsondecode(data.google_secret_manager_secret_version.dsf_passwords.secret_data)["admin_password"]
	secadmin_password 			   = jsondecode(data.google_secret_manager_secret_version.dsf_passwords.secret_data)["secadmin_password"]
	sonarg_pasword 				   = jsondecode(data.google_secret_manager_secret_version.dsf_passwords.secret_data)["sonarg_pasword"]
	sonargd_pasword 			   = jsondecode(data.google_secret_manager_secret_version.dsf_passwords.secret_data)["sonargd_pasword"]
}

# module "sonarg1" {
# 	source  = "../../modules/sonarg"
# 	depends_on = [
# 	  module.sonarw.private_ip
# 	]
# 	region = data.terraform_remote_state.init.outputs.region
# 	name = "${data.terraform_remote_state.init.outputs.environment}-imperva-dsf-agentless-gw1"
# 	subnet_id = var.subnet_id
# 	key_pair = data.terraform_remote_state.init.outputs.key_pair
# 	key_pair_pem_local_path = data.terraform_remote_state.init.outputs.key_pair_pem_local_path
# 	s3_bucket = data.terraform_remote_state.init.outputs.s3_bucket
# 	ec2_instance_type = var.ec2_instance_type
# 	ebs_disk_size = 150
# 	dsf_version = var.dsf_version
# 	dsf_install_tarball_path = var.dsf_install_tarball_path
# 	security_group_ingress_cidrs = var.security_group_ingress_cidrs
# 	dsf_gateway_public_key_name = data.terraform_remote_state.init.outputs.dsf_gateway_sonarw_public_ssh_key_name
# 	dsf_gateway_private_key_name = data.terraform_remote_state.init.outputs.dsf_gateway_sonarw_private_ssh_key_name
# 	dsf_hub_public_authorized_key = data.terraform_remote_state.init.outputs.dsf_hub_sonarw_public_ssh_key_name
# 	dsf_iam_profile_name = data.terraform_remote_state.init.outputs.dsf_iam_profile_name
# 	admin_password = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["admin_password"]
# 	secadmin_password = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["secadmin_password"]
# 	sonarg_pasword = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["sonarg_pasword"]
# 	sonargd_pasword = jsondecode(data.aws_secretsmanager_secret_version.dsf_passwords.secret_string)["sonargd_pasword"]
# 	hub_ip = module.sonarw.private_ip
# }