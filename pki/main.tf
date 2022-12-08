# Copyright (C) 2022 Cochise Ruhulessin
#
# All rights reserved. No warranty, explicit or implicit, provided. In
# no event shall the author(s) be liable for any claim or damages.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
variable "project" { type = string }


resource "google_project_iam_custom_role" "signingKeyUser" {
  project     = var.project
  role_id     = "signingKeyUser"
  title       = "Signing Key User"
  description = "Role for service accounts to use a specific key."
  permissions = [
    "cloudkms.cryptoKeyVersions.get",
    "cloudkms.cryptoKeyVersions.list",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.list",
    "cloudkms.cryptoKeyVersions.viewPublicKey",
    "cloudkms.cryptoKeyVersions.useToSign",
    "cloudkms.cryptoKeyVersions.useToVerify"
  ]
}

resource "google_project_iam_custom_role" "encryptionKeyUser" {
  project     = var.project
  role_id     = "encryptionKeyUser"
  title       = "Encryption Key User"
  description = "Role for service accounts to use a specific encryption key."
  permissions = [
    "cloudkms.cryptoKeyVersions.get",
    "cloudkms.cryptoKeyVersions.list",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.list",
    "cloudkms.cryptoKeyVersions.viewPublicKey",
    "cloudkms.cryptoKeyVersions.useToDecrypt",
    "cloudkms.cryptoKeyVersions.useToEncrypt"
  ]
}