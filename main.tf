terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.61.0"
    }
  }
}


provider "google" {
  credentials = file("balerion.json")

  project = "balerionchatbot"
  region  = "us-central1"
  zone    = "us-central1-c"
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

resource "google_cloud_run_v2_service" "server" {
  name     = "server"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  template {
    containers {
      image = "gcr.io/balerionchatbot/github.com/carlasoffia/balerion_server:latest"
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

// ------------------------------------------------------ RASA CHATBOT ---------------------------------------------------------------


resource "google_cloud_run_v2_service" "chatbot" {
  name     = "chatbot"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  depends_on = [
    resource.google_cloud_run_v2_service.server
  ]
  template {
    containers {
      image = "gcr.io/balerionchatbot/github.com/carlasoffia/balerion_chatbot:latest"
      ports {
        container_port = 5005
      }
      env {
          name  = "DB_host"
          value = "baleriondb.cr9drxfad39n.eu-north-1.rds.amazonaws.com"
      }
      env {
        name  = "DB_user"
        value = "admin"
      }
      env {
          name  = "DB_password"
          value = "secretdb"
      }
      env {
          name  = "DB_port"
          value = "3306"
      }
      env {
        name  = "DB_database"
        value = "balerionDB"
      }
      env {
        name  = "SERVER"
        value = google_cloud_run_v2_service.server.uri
      }
      resources {
        limits = {
          memory = "2048Mi"
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

resource "google_cloud_run_v2_service" "frontend" {
  name     = "frontend"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"
  depends_on = [
    resource.google_cloud_run_v2_service.chatbot
  ]
  template {
    containers {
      image = "gcr.io/balerionchatbot/github.com/carlasoffia/balerion_frontend:latest"
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
