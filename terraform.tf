provider "google" {
  credentials = file("/home/student/terraform/tak-server-drone-project-9ef43fb23ff6.json")
  project    = "tak-server-drone-project"
  region     = "us-east1"
}

variable "vm_names" {
  type = list(string)
  default = ["my-vm2"]
}

resource "google_compute_instance" "example" {
  name         = var.vm_names
  machine_type = "n1-standard-1"
  zone         = "us-east1-b"
  count	       = 2

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20160627"
    }
  }

  # Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    "ssh-keys" = <<EOT
      dev:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILg6UtHDNyMNAh0GjaytsJdrUxjtLy3APXqZfNZhvCeT dev
      test:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILg6UtHDNyMNAh0GjaytsJdrUxjtLy3APXqZfNZhvCeT test
     EOT
  }
}

resource "google_compute_firewall" "allow-ssh" {
  name        = "allow-ssh"
  network     = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]  # Restrict this as needed
}

resource "null_resource" "ansible_provisioner" {
  triggers = {
    instance_id = google_compute_instance.example.id
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i 'localhost,' /home/student/project2/cloud_gallery2.0.yml"
    working_dir = "/home/student/project2/cloud_gallery2.0.yml"
  }
}

output "ssh_user" {
  value = "ubuntu"
}

output "ssh_private_key" {
  value = "/home/student/terraform/tak-server-drone-project-9ef43fb23ff6.json"
}

