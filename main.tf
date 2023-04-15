terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    google = {
      source = "hashicorp/google"
      version = "4.61.0"
    }
  }
}

provider "docker" {}
/*
resource "docker_container" "chatbot" {
  name = "chatbot"
  image = "chatbot"
  ports {
    internal = 5005
    external = 5005
  }
  env = [
    "DB_host=db",
    "DB_user=root",
    "DB_password=secret",
    "DB_database=BalerionMySQL",
    "SERVER=http://server:3000",
    "DB_port=3306",
  ]
}

resource "docker_container" "frontend" {
  name = "frontend"
  image = "frontend"
  ports {
    internal = 8080
    external = 8080
  }
  env = [
    "VUE_APP_RASA=http://localhost:5005/webhooks/rest/webhook",
  ]
}

resource "docker_container" "server" {
  name = "server"
  image = "server"
  ports {
    internal = 3000
    external = 3000
  }
}

resource "docker_container" "db" {
  name = "db"
  image = "mysql"
  restart = "always"
  env = [
    "MYSQL_DATABASE=BalerionMySQL",
    "MYSQL_ROOT_PASSWORD=secret",
  ]
  ports {
    internal = 3306
    external = 3306
  }
  volumes {
    container_path = "/var/lib/mysql"
    host_path = "/database"
    read_only = false
  }
}
*/
// ------------------------------- Google -------------------------------


provider "google" {
  credentials = file("balerion.json")

  project = "balerion-383615"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  lifecycle {
    prevent_destroy = false
  }
}

data "google_container_registry_repository" "balerion" {
}

output "gcr_location" {
  value = data.google_container_registry_repository.balerion.repository_url
}

resource "google_container_registry" "server" {
  location = "EU"
}

data "docker_image" "server" {
  name = "server:latest"
}

resource "null_resource" "gcloud_auth" {
  provisioner "local-exec" {
    command = "gcloud auth configure-docker"
  }
}

# Push the Docker image to the Google Container Registry
resource "null_resource" "push_docker_image" {
  depends_on = [
    data.docker_image.server,
    null_resource.gcloud_auth
  ]

  provisioner "local-exec" {
    command = "docker tag server gcr.io/balerion-383615/server:latest && docker push gcr.io/balerion-383615/server:latest"
  }
}

# Push the Docker image to the Google Container Registry
data "google_container_registry_image" "server" {
  name = "server"
}

# Output the URL of the Google Container Registry
output "gcr_url" {
  value = "${google_container_registry.server}"
}

resource "google_project_iam_member" "run_admin" {
  project = "balerion-383615"
  member  = "serviceAccount:balerion@balerion-383615.iam.gserviceaccount.com"
  role    = "roles/run.admin"
}

resource "google_cloud_run_v2_service" "server" {
  name     = "server"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  depends_on = [
    data.google_container_registry_image.server,
    null_resource.push_docker_image
  ]
  template {
    containers {
        image = "${data.google_container_registry_repository.balerion.repository_url}/server"
        ports {
        container_port = 3000
      }
    }    
  }
}

data "google_iam_policy" "public" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  project = google_cloud_run_v2_service.server.project
  location = google_cloud_run_v2_service.server.location
  name = google_cloud_run_v2_service.server.name
  policy_data = data.google_iam_policy.public.policy_data
  depends_on = [
    resource.google_cloud_run_v2_service.server
  ]
}