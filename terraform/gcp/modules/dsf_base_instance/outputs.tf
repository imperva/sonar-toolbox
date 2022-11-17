output "public_ip" {
  description = "Public Elastic IP address of the DSF base instance"
  value       = module.compute_instance.instances_details.0.network_interface.0.access_config.0.nat_ip
}

output "private_ip" {
  description = "Private IP address of the DSF base instance"
  value       = module.compute_instance.instances_details.0.network_interface.0.network_ip
}
