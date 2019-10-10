#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_compute_instance" "login_node" {
  count        = var.node_count
  name         = "${var.cluster_name}-login${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["login"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      type  = var.boot_disk_type
      size  = var.boot_disk_size
    }
  }

  network_interface {
    access_config {
    }

    subnetwork = var.subnet
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"

    startup-script = <<STARTUP
${templatefile("${path.module}/startup.sh.tmpl",{
apps_dir="${var.apps_dir}",
controller="${var.controller_name}",
nfs_apps_server="${var.nfs_apps_server}",
nfs_home_server="${var.nfs_home_server}"
})}
STARTUP

    packages = <<PACKAGES
${file("${path.module}/packages.txt")}
PACKAGES
  }
}
