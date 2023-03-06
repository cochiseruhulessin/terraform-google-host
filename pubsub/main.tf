# Copyright (C) 2022 Cochise Ruhulessin
#
# All rights reserved. No warranty, explicit or implicit, provided. In
# no event shall the author(s) be liable for any claim or damages.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
variable "events" {
  type = list(string)
}

variable "project_id" {
  type = string
}

variable "project_prefix" {
  type        = string
}

resource "google_pubsub_topic" "global" {
  for_each  = toset(var.events)
  project   = var.project_id
  name      = each.key
}

resource "google_pubsub_topic" "commands" {
  project   = var.project_id
  name      = "${var.project_prefix}.commands"
}

resource "google_pubsub_topic" "keepalive" {
  project   = var.project_id
  name      = "keepalive"
}