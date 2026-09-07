terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.14"
    }
  }
}

resource "mongodbatlas_project" "this" {
  name   = "${var.project_name}-${var.environment}"
  org_id = var.atlas_org_id
}

resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = mongodbatlas_project.this.id
  name         = "${var.project_name}-${var.environment}-cluster"
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.cluster_instance_size
      }
      provider_name         = "TENANT"
      backing_provider_name = "AWS"
      region_name           = var.atlas_region_name
      priority              = 7
    }
  }

  tags {
    key   = "Environment"
    value = var.environment
  }
  tags {
    key   = "Project"
    value = var.project_name
  }
}

resource "mongodbatlas_database_user" "app" {
  username           = var.db_username
  password           = var.db_password
  project_id         = mongodbatlas_project.this.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.database_name
  }
}

resource "mongodbatlas_project_ip_access_list" "app_access" {
  for_each   = toset(var.allowed_cidr_blocks)
  project_id = mongodbatlas_project.this.id
  cidr_block = each.value
  comment    = "Access for Munch Catering application nodes (${each.value})"
}
