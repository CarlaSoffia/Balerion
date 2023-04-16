output "server_url" {
  value = google_cloud_run_v2_service.server.uri
}

output "mysql_url" {
  value = google_cloud_run_v2_service.mysql.uri
}

output "rasa_url" {
  value = google_cloud_run_v2_service.chatbot.uri
}

output "frontend_url" {
  value = google_cloud_run_v2_service.frontend.uri
}