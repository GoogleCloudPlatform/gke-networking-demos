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
All needed pieces for setting up the VPN including Gateways, Tunnels,
FireWalls, Forwarding Rules and Routes
Network, Subnetwork and Static IPs have been already set (in network.tf)
*/

// Setting up Gateways first
resource "google_compute_vpn_gateway" "vpn1-gateway" {
  name    = "vpn1-gateway"
  project = "${var.project}"
  network = "${google_compute_network.network1.self_link}"
  region  = "${var.region1}"
}

resource "google_compute_vpn_gateway" "vpn2-gateway" {
  name    = "vpn2-gateway"
  project = "${var.project}"
  network = "${google_compute_network.network1.self_link}"
  region  = "${var.region2}"
}

resource "google_compute_vpn_gateway" "vpn3-gateway" {
  name    = "vpn3-gateway"
  project = "${var.project}"
  network = "${google_compute_network.network2.self_link}"
  region  = "${var.region1}"
}

resource "google_compute_vpn_gateway" "vpn4-gateway" {
  name    = "vpn4-gateway"
  project = "${var.project}"
  network = "${google_compute_network.network2.self_link}"
  region  = "${var.region2}"
}

// Setting Forwarding Rules
resource "google_compute_forwarding_rule" "vpn1-deployment-fr-esp" {
  name        = "vpn1-deployment-fr-esp"
  region      = "${var.region1}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn1-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn1-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn1-deployment-fr-udp500" {
  name        = "vpn1-deployment-fr-udp500"
  region      = "${var.region1}"
  ip_protocol = "UDP"
  port_range  = 500
  ip_address  = "${google_compute_address.vpn1-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn1-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn1-deployment-fr-udp4500" {
  name        = "vpn1-deployment-fr-udp4500"
  region      = "${var.region1}"
  ip_protocol = "UDP"
  port_range  = 4500
  ip_address  = "${google_compute_address.vpn1-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn1-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn2-deployment-fr-esp" {
  name        = "vpn2-deployment-fr-esp"
  region      = "${var.region2}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn2-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn2-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn2-deployment-fr-udp500" {
  name        = "vpn2-deployment-fr-udp500"
  region      = "${var.region2}"
  ip_protocol = "UDP"
  port_range  = 500
  ip_address  = "${google_compute_address.vpn2-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn2-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn2-deployment-fr-udp4500" {
  name        = "vpn2-deployment-fr-udp4500"
  region      = "${var.region2}"
  ip_protocol = "UDP"
  port_range  = 4500
  ip_address  = "${google_compute_address.vpn2-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn2-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn3-deployment-fr-esp" {
  name        = "vpn3-deployment-fr-esp"
  region      = "${var.region1}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn3-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn3-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn3-deployment-fr-udp500" {
  name        = "vpn3-deployment-fr-udp500"
  region      = "${var.region1}"
  ip_protocol = "UDP"
  port_range  = 500
  ip_address  = "${google_compute_address.vpn3-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn3-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn3-deployment-fr-udp4500" {
  name        = "vpn3-deployment-fr-udp4500"
  region      = "${var.region1}"
  ip_protocol = "UDP"
  port_range  = 4500
  ip_address  = "${google_compute_address.vpn3-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn3-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn4-deployment-fr-esp" {
  name        = "vpn4-deployment-fr-esp"
  region      = "${var.region2}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn4-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn4-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn4-deployment-fr-udp500" {
  name        = "vpn4-deployment-fr-udp500"
  region      = "${var.region2}"
  ip_protocol = "UDP"
  port_range  = 500
  ip_address  = "${google_compute_address.vpn4-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn4-gateway.self_link}"
  project     = "${var.project}"
}

resource "google_compute_forwarding_rule" "vpn4-deployment-fr-udp4500" {
  name        = "vpn4-deployment-fr-udp4500"
  region      = "${var.region2}"
  ip_protocol = "UDP"
  port_range  = 4500
  ip_address  = "${google_compute_address.vpn4-ip-address.address}"
  target      = "${google_compute_vpn_gateway.vpn4-gateway.self_link}"
  project     = "${var.project}"
}

// Setting VPN Tunnels
resource "google_compute_vpn_tunnel" "vpn1-deployment-tunnel" {
  region        = "${var.region1}"
  name          = "vpn1-deployment-tunnel"
  project       = "${var.project}"
  peer_ip       = "${google_compute_address.vpn3-ip-address.address}"
  shared_secret = "gke-to-gke-vpn"
  local_traffic_selector = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
  ike_version = 2

  target_vpn_gateway = "${google_compute_vpn_gateway.vpn1-gateway.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.vpn1-deployment-fr-udp4500"
  ]
}

resource "google_compute_vpn_tunnel" "vpn2-deployment-tunnel" {
  region        = "${var.region2}"
  name          = "vpn2-deployment-tunnel"
  project       = "${var.project}"
  peer_ip       = "${google_compute_address.vpn4-ip-address.address}"
  shared_secret = "gke-to-gke-vpn"
  local_traffic_selector = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
  ike_version = 2

  target_vpn_gateway = "${google_compute_vpn_gateway.vpn2-gateway.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.vpn2-deployment-fr-udp4500"
  ]
}

resource "google_compute_vpn_tunnel" "vpn3-deployment-tunnel" {
  region        = "${var.region1}"
  name          = "vpn3-deployment-tunnel"
  project       = "${var.project}"
  peer_ip       = "${google_compute_address.vpn1-ip-address.address}"
  shared_secret = "gke-to-gke-vpn"
  local_traffic_selector = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
  ike_version = 2

  target_vpn_gateway = "${google_compute_vpn_gateway.vpn3-gateway.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.vpn3-deployment-fr-udp4500"
  ]
}

resource "google_compute_vpn_tunnel" "vpn4-deployment-tunnel" {
  region        = "${var.region2}"
  name          = "vpn4-deployment-tunnel"
  project       = "${var.project}"
  peer_ip       = "${google_compute_address.vpn2-ip-address.address}"
  shared_secret = "gke-to-gke-vpn"
  local_traffic_selector = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
  ike_version = 2

  target_vpn_gateway = "${google_compute_vpn_gateway.vpn4-gateway.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.vpn4-deployment-fr-udp4500"
  ]
}

// Setting up firewalls
resource "google_compute_firewall" "vpn1-firewall" {
  name          = "vpn1-firewall"
  project       = "${var.project}"
  network       = "${google_compute_network.network1.self_link}"
  source_ranges = ["${var.node3-cidr}","${var.cluster3-cidr}","${var.cluster3-srv-cidr}"]
  allow {
    protocol = "tcp"
    protocol = "udp"
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "vpn2-firewall" {
  name          = "vpn2-firewall"
  project       = "${var.project}"
  network       = "${google_compute_network.network1.self_link}"
  source_ranges = ["${var.node4-cidr}","${var.cluster4-cidr}","${var.cluster4-srv-cidr}"]
  allow {
    protocol = "tcp"
    protocol = "udp"
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "vpn3-firewall" {
  name          = "vpn3-firewall"
  project       = "${var.project}"
  network       = "${google_compute_network.network2.self_link}"
  source_ranges = ["${var.node1-cidr}","${var.cluster1-cidr}","${var.cluster1-srv-cidr}"]
  allow {
    protocol = "tcp"
    protocol = "udp"
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "vpn4-firewall" {
  name          = "vpn4-firewall"
  project       = "${var.project}"
  network       = "${google_compute_network.network2.self_link}"
  source_ranges = ["${var.node2-cidr}","${var.cluster2-cidr}","${var.cluster2-srv-cidr}"]
  allow {
    protocol = "tcp"
    protocol = "udp"
    protocol = "icmp"
  }
}

// Setting up Routes
resource "google_compute_route" "vpn1-route1" {
  name        = "vpn1-route1"
  project     = "${var.project}"
  network     = "${google_compute_network.network1.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn1-deployment-tunnel.self_link}"
  dest_range  = "${var.node3-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn1-route2" {
  name        = "vpn1-route2"
  project     = "${var.project}"
  network     = "${google_compute_network.network1.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn1-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster3-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn1-route3" {
  name        = "vpn1-route3"
  project     = "${var.project}"
  network     = "${google_compute_network.network1.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn1-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster3-srv-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn2-route1" {
  name        = "vpn2-route1"
  project     = "${var.project}"
  network     = "${google_compute_network.network1.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn2-deployment-tunnel.self_link}"
  dest_range  = "${var.node4-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn2-route2" {
  name        = "vpn2-route2"
  project     = "${var.project}"
  network     = "${google_compute_network.network1.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn2-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster4-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn2-route3" {
  name        = "vpn2-route3"
  project     = "${var.project}"
  network     = "${google_compute_network.network1.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn2-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster4-srv-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn3-route1" {
  name        = "vpn3-route1"
  project     = "${var.project}"
  network     = "${google_compute_network.network2.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn3-deployment-tunnel.self_link}"
  dest_range  = "${var.node1-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn3-route2" {
  name        = "vpn3-route2"
  project     = "${var.project}"
  network     = "${google_compute_network.network2.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn3-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster1-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn3-route3" {
  name        = "vpn3-route3"
  project     = "${var.project}"
  network     = "${google_compute_network.network2.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn3-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster1-srv-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn4-route1" {
  name        = "vpn4-route1"
  project     = "${var.project}"
  network     = "${google_compute_network.network2.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn4-deployment-tunnel.self_link}"
  dest_range  = "${var.node2-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn4-route2" {
  name        = "vpn4-route2"
  project     = "${var.project}"
  network     = "${google_compute_network.network2.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn4-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster2-cidr}"
  priority    = 100
}

resource "google_compute_route" "vpn4-route3" {
  name        = "vpn4-route3"
  project     = "${var.project}"
  network     = "${google_compute_network.network2.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.vpn4-deployment-tunnel.self_link}"
  dest_range  = "${var.cluster2-srv-cidr}"
  priority    = 100
}

