# Task 2: Create a cloud infrastructure on Google Compute Engine with Terraform

In this task you will create a simple cloud infrastructure that consists of a single VM on Google Compute Engine. It will be
managed by Terraform.

This task is highly inspired from the following guide: [Get started with Terraform](https://cloud.google.com/docs/terraform/get-started-with-terraform).

Create a new Google Cloud project. Save the project ID, it will be used later.

* Name: __labgce__

As we want to create a VM, you need to enable the Compute Engine API:

* [Navigate to google enable api page](https://console.cloud.google.com/flows/enableapi?apiid=compute.googleapis.com)

![EnableAPI](./img/enableAPI.png)

Terraform needs credentials to access the Google Cloud API. Generate and download the Service Account Key:

* Navigate to __IAM & Admin__ > __Service Accounts__. 
* Click on the default service account > __Keys__ and __ADD KEY__ > __Create new key__ (JSON format). 
* On your local machine, create a directory for this lab. In it, create a subdirectory named `credentials` and save the key under the name `labgce-service-account-key.json`, it will be used later.

Generate a public/private SSH key pair that will be used to access the VM and store it in the `credentials` directory:

    ssh-keygen \
      -t ed25519 \
      -f labgce-ssh-key \
      -q \
      -N "" \
      -C ""

At the root of your lab directory, create a `terraform` directory and get the [backend.tf](./appendices/backend.tf), [main.tf](./appendices/main.tf), [outputs.tf](./appendices/outputs.tf) and [variables.tf](./appendices/variables.tf) files. 

These files allow you to deploy a VM, except for a missing file, which you have to provide. Your task is to explore the provided files and using the [Terraform documentation](https://www.terraform.io/docs) understand what these files do. 

The missing file `terraform.tfvars` is supposed to contain values for variables used in the `main.tf` file. Your task is to find out what these values should be. You can freely choose the user account name and the instance name (only lowercase letters, digits and hyphen allowed).

You should have a file structure like this:

    .
    ├── credentials
    │   ├── labgce-service-account-key.json
    │   ├── labgce-ssh-key
    │   └── labgce-ssh-key.pub
    └── terraform
        ├── backend.tf
        ├── main.tf
        ├── outputs.tf
        ├── terraform.tfvars
        └── variables.tf

There are two differences between Google Cloud and AWS that you should know about:

1. Concerning the default Linux system user account created on a VM: In AWS, newly created VMs have a user account that is always named the same for a given OS. For example, Ubuntu VMs have always have a user account named `ubuntu`, CentOS VMs always have a user account named `ec2-user`, and so on. In Google Cloud, the administrator can freely choose the name of the user account.

2. Concerning the public/private key pair used to secure access to the VM: In AWS you create the key pair in AWS and then download the private key. In Google Cloud you create the key pair on your local machine and upload the public key to Google Cloud.

The two preceding parameters are configured in Terraform in the `metadata` section of the `google_compute_instance` resource description. For example, a user account named `fred` with a public key file located at `/path/to/file.pub` is configured as

    metadata = {
      ssh-keys = "fred:${file("/path/to/file.pub")}"
    }
    
This is already taken care of in the provided `main.tf` file.

You can now initialize the Terraform state:

    cd terraform
    terraform init


[OUTPUT]
```bash
Initializing the backend...

Successfully configured the backend "local"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Installing hashicorp/google v5.30.0...
- Installed hashicorp/google v5.30.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
    
* What files were created in the `terraform` directory? Make sure to look also at hidden files and directories (`ls -a`).

[OUTPUT]
```bash
$ tree -a
.
├── .terraform
│   ├── providers
│   │   └── registry.terraform.io
│   │       └── hashicorp
│   │           └── google
│   │               └── 5.30.0
│   │                   └── darwin_arm64
│   │                       ├── LICENSE.txt
│   │                       └── terraform-provider-google_v5.30.0_x5
│   └── terraform.tfstate
├── .terraform.lock.hcl
├── backend.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

* What are they used for?

|File/FolderName|Explanation|
|:--|:--|
|.terraform.lock.hcl|Lock file that ensures the consistency of the provider versions used in the project|
|.terraform|This directory contains the files and the folders needed to manage Terraform plugins and the state of our resources|
|darwin_arm64|Contains the plugin for the Google Cloud provider version 5.30.0 for the darwin_arm64 architecture|
|LICENSE.txt|License file for the plugin|
|terraform-provider-google_v5.30.0_x5|The provider plugin binary|
|.terraform/terraform.tfstate|State file that stores the state of the infrastructure managed by Terraform|


* Check that your Terraform configuration is valid:

```bash
terraform validate
```

[OUTPUT]
```bash
Success! The configuration is valid.
```

* Create an execution plan to preview the changes that will be made to your infrastructure and save it locally:

```bash
terraform plan -input=false -out=.terraform/plan.cache
```

```
Copy the command result in a file named "planCache.json" and add it to your lab repo.
```

The file planCache.json is available [here](./files/planCache.json).

* If satisfied with your execution plan, apply it:

```bash
terraform apply -input=false .terraform/plan.cache
```

```
Copy the command result in a file name "planCacheApplied.txt
```
The file planCacheApplied.txt is available [here](./files/planCacheApplied.txt).

* Test access via ssh

[INPUT]
```bash
 ssh labgce@34.65.53.176 -i labgce-ssh-key
```

[OUTPUT]
```
The authenticity of host '34.65.53.176 (34.65.53.176)' can't be established.
ED25519 key fingerprint is SHA256:fwHUoJgk+xN9DqJqjf4RDKDDOGNDTtKyu0NDxdXoxI0.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '34.65.53.176' (ED25519) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1060-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu May 23 12:44:19 UTC 2024

  System load:  0.13              Processes:             96
  Usage of /:   19.1% of 9.51GB   Users logged in:       0
  Memory usage: 35%               IPv4 address for ens4: 10.172.0.2
  Swap usage:   0%

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

labgce@labgce:~$ 
```

If no errors occur, you have successfully managed to create a VM on Google Cloud using Terraform. You should see the IP of the Google Compute instance in the console. Save the instance IP, it will be used later.

After launching make sure you can SSH into the VM using your private
key and the Linux system user account name defined in the `terraform.tfvars` file.

Deliverables:

* Explain the usage of each provided file and its contents by directly adding comments in the file as needed (we must ensure that you understood what you have done). In the file `variables.tf` fill the missing documentation parts and link to the online documentation. Copy the modified files to the report.

```
# File name : backend.tf

terraform {
  # Defining the global configuration for Terraform
  backend "local" {
    # Using the local backend to store the state
    # The state will be stored in a file named 'terraform.tfstate'
    # in the directory where you run Terraform
  }
}


# File name : main.tf

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


# File name : outputs.tf

# Displays the GCE instance IP address
output "gce_instance_ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}


# File name : variables.tf

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
```

* Explain what the files created by Terraform are used for.

|File/FolderName|Explanation|
|:--|:--|
|.terraform.lock.hcl|Lock file that ensures the consistency of the provider versions used in the project|
|.terraform|This directory contains the files and the folders needed to manage Terraform plugins and the state of our resources|
|darwin_arm64|Contains the plugin for the Google Cloud provider version 5.30.0 for the darwin_arm64 architecture|
|LICENSE.txt|License file for the plugin|
|terraform-provider-google_v5.30.0_x5|The provider plugin binary|
|.terraform/terraform.tfstate|State file that stores the state of the infrastructure managed by Terraform|

* Where is the Terraform state saved? Imagine you are working in a team and the other team members want to use Terraform, too, to manage the cloud infrastructure. Do you see any problems with this? Explain.

```
As specified in our configuration the Terraform state is stored locally, we will have some problems :
- If multiple people simultaneously change the infrastructure. This can result in conflicts and unpredictable behavior.
- The state is stored in a single file. If this file is corrupted it ca cause errors
- Terraform provides a mechanism called state locking. This feature help to prevent concurrent operations on the state file. If it's not implement correcty. It can cause issue.
- Difficult to manage changes and track who made specific modifications. It's occur whent a single state file is shared between the teams.
```

* What happens if you reapply the configuration (1) without changing `main.tf` (2) with a change in `main.tf`? Do you see any changes in Terraform's output? Why? Can you think of examples where Terraform needs to delete parts of the infrastructure to be able to reconfigure it?

```
Reapplying the configuration without changes results in no action by Terraform.
If we make change in 'maint.tf' Terafform generate a plan and update the infrastucture.
In some case, some changes require to delete and recreate ressources. This case is when dealing with immutable attributes, renaming resources, altering dependencies, network setting. 
```

* Explain what you would need to do to manage multiple instances.

```
We can add a 'count' parameter.
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 3
}

We also have 'for_each? for specific configuration with one or multiple instances.
```

* Take a screenshot of the Google Cloud Console showing your Google Compute instance and put it in the report.

```

```
![](.\img\gce-instance.png)

* Deliver a folder "terraform" with your configuration.
