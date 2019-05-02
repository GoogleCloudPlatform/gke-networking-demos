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
Creating Clusters and their Node Pools
*/

# Gets the current version of Kubernetes engine
data "google_container_engine_versions" "gke_version" {
  location = "us-east1-b"
  project  = "${var.project}"
}

// Install the first cluster
resource "google_container_cluster" "cluster-deployment-cluster1" {
  name               = "cluster-deployment-cluster1"
  project            = "${var.project}"
  location           = "${var.cluster1-location}"
  network            = "${google_compute_network.network1.self_link}"
  subnetwork         = "${google_compute_subnetwork.subnet1-us-east1.self_link}"
  initial_node_count = "1"
  node_locations     = []
  min_master_version = "${data.google_container_engine_versions.gke_version.latest_master_version}"
  ip_allocation_policy {
    use_ip_aliases     = "true"
    cluster_ipv4_cidr_block = "${var.cluster1-cidr}"
    services_ipv4_cidr_block = "${var.cluster1-srv-cidr}"
  }
}

// Install node-pool for the first cluster. It's recommended by Terraform to be in a seperate block than main cluster
resource "google_container_node_pool" "cluster1_nodes" {
    name       = "cluster1-nodes"
    location   = "${var.cluster1-location}"
    project    = "${var.project}"
    cluster    = "${google_container_cluster.cluster-deployment-cluster1.name}"
    node_config {
      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]
      image_type   = "COS"
      tags = ["kc-node"]
    }
}

// Install the second cluster
resource "google_container_cluster" "cluster-deployment-cluster2" {
  name               = "cluster-deployment-cluster2"
  project            = "${var.project}"
  location           = "${var.cluster2-location}"
  network            = "${google_compute_network.network1.self_link}"
  subnetwork         = "${google_compute_subnetwork.subnet2-us-central1.self_link}"
  initial_node_count = "1"
  node_locations     = []
  min_master_version = "${data.google_container_engine_versions.gke_version.latest_master_version}"
  ip_allocation_policy {
    use_ip_aliases     = "true"
    cluster_ipv4_cidr_block = "${var.cluster2-cidr}"
    services_ipv4_cidr_block = "${var.cluster2-srv-cidr}"
  }
}

// Install node-pool for the second cluster.
resource "google_container_node_pool" "cluster2_nodes" {
    name       = "cluster2-nodes"
    location   = "${var.cluster2-location}"
    project    = "${var.project}"
    cluster    = "${google_container_cluster.cluster-deployment-cluster2.name}"
    node_config {
      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]
      image_type   = "COS"
      tags = ["kc-node"]
    }
}

// Install the third cluster
resource "google_container_cluster" "cluster-deployment-cluster3" {
  name               = "cluster-deployment-cluster3"
  project            = "${var.project}"
  location           = "${var.cluster3-location}"
  network            = "${google_compute_network.network2.self_link}"
  subnetwork         = "${google_compute_subnetwork.subnet3-us-east1.self_link}"
  initial_node_count = "1"
  node_locations     = []
  min_master_version = "${data.google_container_engine_versions.gke_version.latest_master_version}"
  ip_allocation_policy {
    use_ip_aliases     = "true"
    cluster_ipv4_cidr_block = "${var.cluster3-cidr}"
    services_ipv4_cidr_block = "${var.cluster3-srv-cidr}"
  }
}

// Install node-pool for the third cluster.
resource "google_container_node_pool" "cluster3_nodes" {
    name       = "cluster3-nodes"
    location   = "${var.cluster3-location}"
    project    = "${var.project}"
    cluster    = "${google_container_cluster.cluster-deployment-cluster3.name}"
    node_config {
      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]
      image_type   = "COS"
      tags = ["kc-node"]
    }
}

// Install the forth cluster
resource "google_container_cluster" "cluster-deployment-cluster4" {
  name               = "cluster-deployment-cluster4"
  project            = "${var.project}"
  location           = "${var.cluster4-location}"
  network            = "${google_compute_network.network2.self_link}"
  subnetwork         = "${google_compute_subnetwork.subnet4-us-central1.self_link}"
  initial_node_count = "1"
  node_locations     = []
  min_master_version = "${data.google_container_engine_versions.gke_version.latest_master_version}"
  ip_allocation_policy {
    use_ip_aliases     = "true"
    cluster_ipv4_cidr_block = "${var.cluster4-cidr}"
    services_ipv4_cidr_block = "${var.cluster4-srv-cidr}"
  }
}

// Install node-pool for the forth cluster.
resource "google_container_node_pool" "cluster4_nodes" {
    name       = "cluster4-nodes"
    location   = "${var.cluster4-location}"
    project    = "${var.project}"
    cluster    = "${google_container_cluster.cluster-deployment-cluster4.name}"
    node_config {
      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]
      image_type   = "COS"
      tags = ["kc-node"]
    }
}

