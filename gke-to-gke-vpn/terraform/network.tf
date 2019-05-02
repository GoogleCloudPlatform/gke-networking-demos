/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/*
This will setup basic underlying network vpn.tf
It will setup Networks, IPs and Subnetworks
*/

// Setting up Static IP Addresses
resource "google_compute_address" "vpn1-ip-address" {
  name    = "vpn1-ip-address"
  project = "${var.project}"
  region  = "${var.region1}"
}

resource "google_compute_address" "vpn2-ip-address" {
  name    = "vpn2-ip-address"
  project = "${var.project}"
  region  = "${var.region2}"
}

resource "google_compute_address" "vpn3-ip-address" {
  name    = "vpn3-ip-address"
  project = "${var.project}"
  region  = "${var.region1}"
}

resource "google_compute_address" "vpn4-ip-address" {
  name    = "vpn4-ip-address"
  project = "${var.project}"
  region  = "${var.region2}"
}

// Setting up 4 subnets for our 2 networks
resource "google_compute_subnetwork" "subnet1-us-east1" {
  name          = "subnet1-us-east1"
  project       = "${var.project}"
  ip_cidr_range = "${var.node1-cidr}"
  network       = "${google_compute_network.network1.self_link}"
  region        = "${var.region1}"
}

resource "google_compute_subnetwork" "subnet2-us-central1" {
  name          = "subnet2-us-central1"
  project       = "${var.project}"
  ip_cidr_range = "${var.node2-cidr}"
  network       = "${google_compute_network.network1.self_link}"
  region        = "${var.region2}"
}

resource "google_compute_subnetwork" "subnet3-us-east1" {
  name          = "subnet3-us-east1"
  project       = "${var.project}"
  ip_cidr_range = "${var.node3-cidr}"
  network       = "${google_compute_network.network2.self_link}"
  region        = "${var.region1}"
}

resource "google_compute_subnetwork" "subnet4-us-central1" {
  name          = "subnet4-us-central1"
  project       = "${var.project}"
  ip_cidr_range = "${var.node4-cidr}"
  network       = "${google_compute_network.network2.self_link}"
  region        = "${var.region2}"
}

// Setting 2 networks
resource "google_compute_network" "network1" {
  name                    = "${var.network1}"
  project                 = "${var.project}"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network2" {
  name                    = "${var.network2}"
  project                 = "${var.project}"
  auto_create_subnetworks = false
}



