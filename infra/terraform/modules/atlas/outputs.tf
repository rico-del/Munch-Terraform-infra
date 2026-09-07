output "project_id" {
  value       = mongodbatlas_project.this.id
  description = "MongoDB Atlas project ID."
}

output "cluster_id" {
  value       = mongodbatlas_advanced_cluster.this.cluster_id
  description = "MongoDB Atlas cluster ID."
}

output "connection_string" {
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv
  description = "Standard SRV MongoDB connection string."
}

output "app_mongo_uri" {
  value       = "mongodb+srv://${var.db_username}:${var.db_password}@${replace(mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv, "mongodb+srv://", "")}/${var.database_name}?retryWrites=true&w=majority"
  description = "Full authenticated MongoDB connection URI for the application."
  sensitive   = true
}
