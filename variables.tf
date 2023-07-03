# Copyright (C) 2022 Cochise Ruhulessin
#
# All rights reserved. No warranty, explicit or implicit, provided. In
# no event shall the author(s) be liable for any claim or damages.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
variable "billing_account" {
  description = "The Google billing account to use."
  type        = string
}

variable "events" {
  type        = list(string)
  default     = []
  description = "A list of string specifying the events for this system."
}

variable "logging_location" {
  type        = string
  description = "The storage location of common project logs."
}

variable "project_prefix" {
  type        = string
  description = "The prefix used to create the project identifier."
}

variable "project_name" {
  type        = string
  description = "The host project display name."
}

variable "organization_id" {
  type        = string
  description = "The organization identifier for the Google organization owning the project."
}

variable "service_network" {
  type        = string
  default     = "services"
  description = "Default network for VPC services"
}
