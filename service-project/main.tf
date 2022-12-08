# Copyright (C) 2022 Cochise Ruhulessin
#
# All rights reserved. No warranty, explicit or implicit, provided. In
# no event shall the author(s) be liable for any claim or damages.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
variable "billing_account" {
  type = string
}

variable "enabled_services" {
  type    = list(string)
  default = []
}

variable "host_project" {
  type = string
}

variable "organization_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "service_project" {
  type = string
}

resource "google_project" "service" {
  project_id      = var.service_project
  name            = var.project_name
  billing_account = var.billing_account
  org_id          = var.organization_id
}

resource "google_project_service" "required" {
  for_each = toset(
    concat(
      ["compute.googleapis.com"],
      var.enabled_services
    )
  )
  project            = google_project.service.project_id
  service            = each.key
  disable_on_destroy = false
  depends_on         = [google_project.service]

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_compute_shared_vpc_service_project" "services" {
  host_project    = var.host_project
  service_project = var.service_project

  depends_on      = [
    google_project.service,
    google_project_service.required,
  ]
}