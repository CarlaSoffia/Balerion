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
    "VUE_APP_chatbot=http://localhost:5005/webhooks/rest/webhook",
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

resource "null_resource" "gcloud_auth" {
  provisioner "local-exec" {
    command = "gcloud auth configure-docker"
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

// ----------------------------------------------------------- SERVER ------------------------------------------------------------
resource "google_container_registry" "server" {
  location = "EU"
}

data "docker_image" "server" {
  name = "server:latest"
}

# Push the Docker image to the Google Container Registry
resource "null_resource" "push_docker_image_server" {
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

resource "google_cloud_run_v2_service" "server" {
  name     = "server"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  depends_on = [
    data.google_container_registry_image.server,
    null_resource.push_docker_image_server
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

resource "google_cloud_run_v2_service_iam_policy" "policyServer" {
  project = google_cloud_run_v2_service.server.project
  location = google_cloud_run_v2_service.server.location
  name = google_cloud_run_v2_service.server.name
  policy_data = data.google_iam_policy.public.policy_data
  depends_on = [
    resource.google_cloud_run_v2_service.server
  ]
}

// ------------------------------------------------------ DATABASE ---------------------------------------------------------------

resource "google_container_registry" "mysql" {
  location = "EU"
}

data "docker_image" "mysql" {
  name = "mysql:latest"
}

# Push the Docker image to the Google Container Registry
resource "null_resource" "push_docker_image_mySQL" {
  depends_on = [
    data.docker_image.mysql,
    null_resource.gcloud_auth
  ]

  provisioner "local-exec" {
    command = "docker tag mysql gcr.io/balerion-383615/mysql:latest && docker push gcr.io/balerion-383615/mysql:latest"
  }
}

# Push the Docker image to the Google Container Registry
data "google_container_registry_image" "mysql" {
  name = "mysql"
}

resource "google_cloud_run_v2_service" "mysql" {
  name     = "mysql"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  depends_on = [
    data.google_container_registry_image.mysql,
    null_resource.push_docker_image_mySQL
  ]
  template {
    containers {
      image = "${data.google_container_registry_repository.balerion.repository_url}/mysql"
      ports {
        container_port = 3306
      }
      env {
          name  = "MYSQL_DATABASE"
          value = "BalerionMySQL"
      }
      env {
        name  = "MYSQL_ROOT_PASSWORD"
        value = "secret"
      }
      resources {
        limits = {
          memory = "1Gi"
        }
      }  
    }
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policyMySQL" {
  project = google_cloud_run_v2_service.mysql.project
  location = google_cloud_run_v2_service.mysql.location
  name = google_cloud_run_v2_service.mysql.name
  policy_data = data.google_iam_policy.public.policy_data
  depends_on = [
    resource.google_cloud_run_v2_service.mysql
  ]
}

// ------------------------------------------------------ RASA CHATBOT ---------------------------------------------------------------


resource "google_container_registry" "chatbot" {
  location = "EU"
}

data "docker_image" "chatbot" {
  name = "chatbot:latest"
}

# Push the Docker image to the Google Container Registry
resource "null_resource" "push_docker_image_chatbot" {
  depends_on = [
    data.docker_image.chatbot,
    null_resource.gcloud_auth
  ]

  provisioner "local-exec" {
    command = "docker tag chatbot gcr.io/balerion-383615/chatbot:latest && docker push gcr.io/balerion-383615/chatbot:latest"
  }
}

# Push the Docker image to the Google Container Registry
data "google_container_registry_image" "chatbot" {
  name = "chatbot"
}

resource "google_cloud_run_v2_service" "chatbot" {
  name     = "chatbot"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  depends_on = [
    data.google_container_registry_image.chatbot,
    null_resource.push_docker_image_chatbot,
    resource.google_cloud_run_v2_service.server,
    resource.google_cloud_run_v2_service.server,
  ]
  template {
    containers {
      image = "${data.google_container_registry_repository.balerion.repository_url}/chatbot"
      ports {
        container_port = 5005
      }
      env {
          name  = "DB_host"
          value = google_cloud_run_v2_service.mysql.uri
      }
      env {
        name  = "DB_user"
        value = "root"
      }
      env {
          name  = "DB_password"
          value = "secret"
      }
      env {
        name  = "DB_database"
        value = "BalerionMySQL"
      }
      env {
        name  = "SERVER"
        value = google_cloud_run_v2_service.server.uri
      }
      resources {
        limits = {
          memory = "1050Mi"
        }
      } 
    }
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policyChatbot" {
  project = google_cloud_run_v2_service.chatbot.project
  location = google_cloud_run_v2_service.chatbot.location
  name = google_cloud_run_v2_service.chatbot.name
  policy_data = data.google_iam_policy.public.policy_data
  depends_on = [
    resource.google_cloud_run_v2_service.chatbot
  ]
}

// ----------------------------------------------------------- FRONTEND ------------------------------------------------------------
resource "google_container_registry" "frontend" {
  location = "EU"
}

data "docker_image" "frontend" {
  name = "frontend:latest"
}

# Push the Docker image to the Google Container Registry
resource "null_resource" "push_docker_image_frontend" {
  depends_on = [
    data.docker_image.frontend,
    null_resource.gcloud_auth
  ]

  provisioner "local-exec" {
    command = "docker tag frontend gcr.io/balerion-383615/frontend:latest && docker push gcr.io/balerion-383615/frontend:latest"
  }
}

# Push the Docker image to the Google Container Registry
data "google_container_registry_image" "frontend" {
  name = "frontend"
}

resource "google_cloud_run_v2_service" "frontend" {
  name     = "frontend"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  depends_on = [
    data.google_container_registry_image.frontend,
    null_resource.push_docker_image_frontend,
    resource.google_cloud_run_v2_service.chatbot
  ]
  template {
    containers {
      image = "${data.google_container_registry_repository.balerion.repository_url}/frontend"
      ports {
        container_port = 8080
      }
      env {
        name  = "VUE_APP_RASA"
        value = "${google_cloud_run_v2_service.chatbot.uri}/webhooks/rest/webhook"
      }
    }    
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policyFrontend" {
  project = google_cloud_run_v2_service.frontend.project
  location = google_cloud_run_v2_service.frontend.location
  name = google_cloud_run_v2_service.frontend.name
  policy_data = data.google_iam_policy.public.policy_data
  depends_on = [
    resource.google_cloud_run_v2_service.frontend
  ]
}