terraform {
  # Defining the global configuration for Terraform
  backend "local" {
    # Using the local backend to store the state
    # The state will be stored in a file named 'terraform.tfstate'
    # in the directory where you run Terraform
  }
}
