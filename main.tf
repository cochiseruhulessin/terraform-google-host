# Copyright (C) 2022 Cochise Ruhulessin
#
# All rights reserved. No warranty, explicit or implicit, provided. In
# no event shall the author(s) be liable for any claim or damages.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
locals {
  project_id = "${var.project_prefix}-${random_string.project_suffix.result}"
}

# Generate a random suffic for the host project.
resource "random_string" "project_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "google_project" "host" {
  project_id      = local.project_id
  name            = var.project_name
  billing_account = var.billing_account
  org_id          = var.organization_id
}

resource "google_logging_project_bucket_config" "default" {
  depends_on = [google_project.host]
  project    = google_project.host.project_id
  location  = var.logging_location
  retention_days = 30
  bucket_id = "services-default"
}

resource "google_project_service" "required" {
  for_each = toset(
    concat([
      "cloudkms.googleapis.com",
      "compute.googleapis.com",
      "dns.googleapis.com",
      "eventarc.googleapis.com",
    ],
  ))
  project            = google_project.host.project_id
  service            = each.key
  disable_on_destroy = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.host.project_id
}

module "events" {
  depends_on = [google_project.host]
  source     = "./pubsub"
  events     = var.events
  project_id = local.project_id
}