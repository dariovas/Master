provider "google" {
  project     = var.gcp_project_id # The GCP project ID
  region      = "europe-west6-a" # The region used for resources
  credentials = file("${var.gcp_service_account_key_file_path}") # Path to the GCP service account key file which will allow us to deploy resources to the cloud.
}

resource "google_compute_instance" "default" {
  name         = var.gce_instance_name # The Google Compute Engine instance name
  machine_type = "f1-micro" # The machine type for the instance
  zone         = "europe-west6-a" # The zone in which the instance will be deployed

  metadata = {
    # Set the ssh key for the instance
    ssh-keys = "${var.gce_instance_user}:${file("${var.gce_ssh_pub_key_file_path}")}" 
  }

  # Boot disk image for the instance
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Network configuration for the instance
  network_interface {
    network = "default"

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_firewall" "ssh" {
  name          = "allow-ssh" # Name of the firewall rule
  network       = "default" # Network for the firewall rule
  source_ranges = ["0.0.0.0/0"] # Source IP ranges allowed to access
  allow {
    ports    = ["22"] # Allows SSH port
    protocol = "tcp" # Protocol used by the rule
  }
}

resource "google_compute_firewall" "http" {
  name          = "allow-http" # Name of the firewall rule
  network       = "default" # Network for the firewall rule
  source_ranges = ["0.0.0.0/0"] # Source IP ranges allowed to access
  allow {
    ports    = ["80"] # Allows HTTP port
    protocol = "tcp" # Protocol used by the rule
  }
}
