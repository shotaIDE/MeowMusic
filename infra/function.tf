variable "firebase_admin_key_file_name" {
  type        = string
  default     = "firebase-serviceAccountKey_dev.json"
  description = "Service account key JSON file name for Firebase admin."
}

variable "google_application_credentials" {
  type        = string
  default     = "cloud-tasks-serviceAccountKey_dev.json"
  description = "Service account key JSON file name for Cloud tasks."
}

variable "revenue_cat_public_apple_api_key" {
  type        = string
  default     = ""
  description = "Public Apple API key for RevenueCat."
}

variable "revenue_cat_public_google_api_key" {
  type        = string
  default     = ""
  description = "Public Google API key for RevenueCat."
}

variable "feature_eliminate_waiting_time_to_generate" {
  type        = string
  default     = "true"
  description = "Is enabled the feature to eliminate waiting time to generate pieces depends on Premium Plan."
}

variable "waiting_time_seconds_to_generate" {
  type        = string
  default     = "300"
  description = "Waiting time seconds to generate pieces."
}

locals {
  runtime = "python310"
  docker_registry = "CONTAINER_REGISTRY"
  https_trigger_security_level = "SECURE_OPTIONAL"
  timeout = "10m"
  environment_variables = {
    "FIREBASE_ADMIN_KEY_FILE_NAME" = var.firebase_admin_key_file_name
    "FIREBASE_STORAGE_BUCKET_NAME" = google_storage_bucket.default.name
    "FIREBASE_FUNCTIONS_API_ORIGIN" = "https://${var.google_project_location}-${google_project.default.project_id}.cloudfunctions.net"
    "GOOGLE_APPLICATION_CREDENTIALS" = var.google_application_credentials
    "GOOGLE_CLOUD_PROJECT_ID" = google_project.default.project_id
    "GOOGLE_CLOUD_TASKS_LOCATION" = var.google_project_location
    "GOOGLE_CLOUD_TASKS_QUEUE_ID" = google_cloud_tasks_queue.advanced_configuration.name
    "REVENUE_CAT_PUBLIC_APPLE_API_KEY" = var.revenue_cat_public_apple_api_key
    "REVENUE_CAT_PUBLIC_GOOGLE_API_KEY" = var.revenue_cat_public_google_api_key
    "FEATURE_ELIMINATE_WAITING_TIME_TO_GENERATE" = var.feature_eliminate_waiting_time_to_generate
    "WAITING_TIME_SECONDS_TO_GENERATE" = var.waiting_time_seconds_to_generate
  }
}

data "archive_file" "functions_src" {
  type        = "zip"
  source_dir  = "../function2"
  output_path = "./function.zip"
}

resource "google_storage_bucket_object" "functions_src" {
  name   = "functions/src_${data.archive_file.functions_src.output_md5}.zip"
  bucket = google_storage_bucket.default.name
  source = data.archive_file.functions_src.output_path

  depends_on = [
    google_firebase_project.default,
  ]
}

resource "google_cloudfunctions_function" "detect" {
  name                         = "detect"
  runtime                      = local.runtime
  source_archive_bucket        = google_storage_bucket.default.name
  source_archive_object        = google_storage_bucket_object.functions_src.name
  trigger_http                 = true
  available_memory_mb          = 2048
  timeout                      = 60
  entry_point                  = "detect"
  docker_registry              = local.docker_registry
  https_trigger_security_level = local.https_trigger_security_level
  max_instances                = 1
  min_instances                = 0
  environment_variables = local.environment_variables

  timeouts {
    create = local.timeout
  }
}

resource "google_cloudfunctions_function" "submit" {
  name                         = "submit"
  runtime                      = local.runtime
  source_archive_bucket        = google_storage_bucket.default.name
  source_archive_object        = google_storage_bucket_object.functions_src.name
  trigger_http                 = true
  available_memory_mb          = 1024
  timeout                      = 60
  entry_point                  = "submit"
  docker_registry              = local.docker_registry
  https_trigger_security_level = local.https_trigger_security_level
  max_instances                = 1
  min_instances                = 0
  environment_variables = local.environment_variables

  timeouts {
    create = local.timeout
  }
}

resource "google_cloudfunctions_function" "piece" {
  name                         = "piece"
  runtime                      = local.runtime
  source_archive_bucket        = google_storage_bucket.default.name
  source_archive_object        = google_storage_bucket_object.functions_src.name
  trigger_http                 = true
  available_memory_mb          = 1024
  timeout                      = 60
  entry_point                  = "piece"
  docker_registry              = local.docker_registry
  https_trigger_security_level = local.https_trigger_security_level
  max_instances                = 1
  min_instances                = 0
  environment_variables = local.environment_variables

  timeouts {
    create = local.timeout
  }
}
