variable "gcp_project_id" {
  description = "ID of the Google cloud Platform project"
  type        = string
  nullable    = false
  # Documentation : https://developer.hashicorp.com/terraform/language/values/variables
}

variable "gcp_service_account_key_file_path" {
  description = "File path to the GCP service account key file"
  type        = string
  nullable    = false
  # Documentation : https://developer.hashicorp.com/terraform/language/values/variables
}

variable "gce_instance_name" {
  description = "Google Compute Engine instance name"
  type        = string
  nullable    = false
  # Documentation : https://developer.hashicorp.com/terraform/language/values/variables
}

variable "gce_instance_user" {
  description = "Username for SSH access to the instance"
  type        = string
  nullable    = false
  # Documentation : https://developer.hashicorp.com/terraform/language/values/variables
}

variable "gce_ssh_pub_key_file_path" {
  description = "File path to the SSH public key file"
  type        = string
  nullable    = false
  # Documentation : https://developer.hashicorp.com/terraform/language/values/variables
}
