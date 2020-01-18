#
#  Use a GCP Cloud Storage backend to hold the terraform state
#
terraform {
  backend "gcs" {
    bucket = "lithos-terraform-state-prod"
    prefix = "terraform/state"
  }
}

resource "google_container_cluster" "primary" {
  name     = "maplarge"
  location = "${var.GCP_REGION}"
  project  = "${var.GCP_PROJECT}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node-pool"
  location   = "${var.GCP_REGION}"
  project    = "${var.GCP_PROJECT}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-64"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }
}

# This should be manually created, not via terraform
resource "kubernetes_secret" "maplarge-secret" {
  metadata {
    name = "maplarge-root-password-secret"
  }

  data = {
    password = "xxxxxxxx"
  }

  type = "Opaque"
}

#
#  IP to allow service calls to come in from within the GCP network
#
resource "kubernetes_service" "maplarge-service" {

  metadata {
    name = "maplarge-service"
  }
  spec {
    selector = {
      app = "maplarge_application"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "google_compute_disk" "maplarge-persistent-disk" {
  name  = "maplarge-persistent-disk"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  project = "${var.GCP_PROJECT}"
  labels = {
    environment = "prod"
  }
  physical_block_size_bytes = 4096
}

# The type of disk we will want to use in the Volume Storage Claim
resource "kubernetes_storage_class" "maplarge-ssd-storage" {
  metadata {
    name = "maplarge-ssd-storage"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  reclaim_policy      = "Retain"
  parameters = {
    type = "pd-ssd"
  }
}



  # Persistent Volume Claim

resource "kubernetes_persistent_volume" "maplarge-master-storage" {
  metadata {
    name = "maplarge-master-storage"
  }
  lifecycle {
    prevent_destroy = true
  }
  spec {
    capacity = {
      storage = "100Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = "maplarge-persistent-disk"
      }
    }
  }
}

#
# Composer configuration  (add this back in when google provider support python version 3)
#
# resource "google_composer_environment" "lithos" {
#   name = "lithos"
#   region = "us-central1"
#   project = "${var.GCP_PROJECT}"

#   config {
#     node_count = 3
#     node_config {
#       zone = "us-central1-a"
#       machine_type = "n1-standard-1"
#     }
#     software_config {
#       airflow_config_overrides = {
#         core-load_example = "True"
#       }
#       python_version = "3"

#       pypi_packages = {
#         numpy = ">=1.16.1"
#       }

#       env_variables = {
#          FOO = "bar"
#       }
#     }
#   }
# }