variable "name" {
  type = string
  default = "octo-dsf"
}

variable "location" {
  type = string
  default = "East US"
}

variable "azurerm_resource_group_name" {
  type    = string
  default = "octo-isbt"
}

variable "dsf_vnet" {
  type    = string
  default = "Octo-terraform-dsf-vnet"
}

variable "security_group_ingress_cidrs" {
  type        = list(any)
  description = "List of allowed ingress cidr patterns for the DSF agentless gw instance"
  default     = ["75.80.37.59/32", "134.238.194.108/32", "172.20.0.0/16", "137.83.248.39/32"]
}

variable "amd_disk_size" {
  type = number
  validation {
    condition     = var.amd_disk_size >= 100
    error_message = "DSF base instance disk size must be at least 100GB."
  }
  default = 100
}
