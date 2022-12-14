# Copyright (C) 2022 Cochise Ruhulessin
#
# All rights reserved. No warranty, explicit or implicit, provided. In
# no event shall the author(s) be liable for any claim or damages.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
locals {
  nat_project_id                = "${var.project_prefix}-${random_string.project_suffix.result}-nat"
  project_id                    = "${var.project_prefix}-${random_string.project_suffix.result}"
  services_project_id           = "${var.project_prefix}-${random_string.project_suffix.result}-svc"
  pki_project_id                = "${var.project_prefix}-${random_string.project_suffix.result}-pki"
  public_networking_project_id  = "${var.project_prefix}-${random_string.project_suffix.result}-lb"
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

module "public-networking-project" {
  source          = "./service-project"
  billing_account = var.billing_account
  host_project    = google_project.host.project_id
  organization_id = var.organization_id
  project_name    = "${var.project_name} LB"
  service_project = local.public_networking_project_id

  depends_on = [
    google_project.host,
    google_compute_shared_vpc_host_project.host
  ]
}

module "services-project" {
  source          = "./service-project"
  billing_account = var.billing_account
  host_project    = google_project.host.project_id
  organization_id = var.organization_id
  project_name    = "${var.project_name} SVC"
  service_project = local.services_project_id

  depends_on = [
    google_project.host,
    google_compute_shared_vpc_host_project.host
  ]

  enabled_services = [
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudscheduler.googleapis.com",
    "eventarc.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}

module "pki-project" {
  source          = "./service-project"
  billing_account = var.billing_account
  host_project    = google_project.host.project_id
  organization_id = var.organization_id
  project_name    = "${var.project_name} PKI"
  service_project = local.pki_project_id

  depends_on = [
    google_project.host,
    google_compute_shared_vpc_host_project.host
  ]

  enabled_services = [
    "cloudkms.googleapis.com",
  ]
}

resource "google_logging_project_bucket_config" "default" {
  depends_on = [google_project.host]
  project    = google_project.host.project_id
  location  = var.logging_location
  retention_days = 30
  bucket_id = "services-default"
}

resource "google_project_service" "required" {
  for_each = toset([
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "eventarc.googleapis.com",
  ])
  project            = google_project.host.project_id
  service            = each.key
  disable_on_destroy = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_compute_shared_vpc_host_project" "host" {
  project     = google_project.host.project_id
  depends_on  = [google_project_service.required]
}

module "events" {
  depends_on = [module.services-project]
  source     = "./pubsub"
  events     = var.events
  project_id = local.services_project_id
}

module "registry" {
  source  = "./registry"
  project = local.services_project_id

  depends_on = [module.services-project]
}

module "pki" {
  source  = "./pki"
  project = local.pki_project_id

  depends_on = [module.pki-project]
}

output "host_project" {
  value = local.project_id
}

output "public_networking_project_id" {
  value = local.public_networking_project_id
}