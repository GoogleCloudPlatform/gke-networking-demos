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
Variables for the creation of the cluster, bastion, subnet and network.
See https://www.terraform.io/docs/configuration/variables.html
*/

variable "project" {
  description = "The project in which to hold the components"
  type        = "string"
}

variable "vpn-deployments" {
  description = "Name of all VPN Deployments"
  type = "list"
  default = ["vpn1-deployment", "vpn2-deployment", "vpn3-deployment", "vpn4-deployment"]
}

variable "vpn-regions" {
  description = "Regions for VPNs"
  type = "list"
  default = ["us-east1", "us-central1", "us-east1", "us-central1"]
}

variable "network1" {
  description = "Name of VPN Network 1"
  type = "string"
  default = "network1"
}

variable "network2" {
  description = "Name of VPN Network 2"
  type = "string"
  default = "network2"
}

// The region in which to deploy first regionally-scoped resources
variable "region1" {
  description = "Name of Region1"
  type = "string"
  default = "us-east1"
}

// The region in which to deploy second regionally-scoped resources
variable "region2" {
  description = "Name of Region2"
  type = "string"
  default = "us-central1"
}

// Cluster variables
variable "cluster1-location" {
  description = "Location of Cluster1"
  type = "string"
  default = "us-east1-d"
}

variable "cluster1-cidr" {
  description = "CIDR block for Cluster1"
  type = "string"
  default = "10.108.0.0/19"
}

variable "cluster1-srv-cidr" {
  description = "Service CIDR block for Cluster1"
  type = "string"
  default = "10.208.0.0/20"
}

variable "cluster2-location" {
  description = "Location of Cluster2"
  type = "string"
  default = "us-central1-b"
}

variable "cluster2-cidr" {
  description = "CIDR block for Cluster2"
  type = "string"
  default = "10.118.0.0/19"
}

variable "cluster2-srv-cidr" {
  description = "Service CIDR block for Cluster2"
  type = "string"
  default = "10.218.0.0/20"
}

variable "cluster3-location" {
  description = "Location of Cluster3"
  type = "string"
  default = "us-east1-c"
}

variable "cluster3-cidr" {
  description = "CIDR block for Cluster3"
  type = "string"
  default = "10.128.0.0/19"
}

variable "cluster3-srv-cidr" {
  description = "Service CIDR block for Cluster3"
  type = "string"
  default = "10.228.0.0/20"
}

variable "cluster4-location" {
  description = "Location of Cluster4"
  type = "string"
  default = "us-central1-c"
}

variable "cluster4-cidr" {
  description = "CIDR block for Cluster4"
  type = "string"
  default = "10.138.0.0/19"
}

variable "cluster4-srv-cidr" {
  description = "Service CIDR block for Cluster4"
  type = "string"
  default = "10.238.0.0/20"
}

// Network variables
variable "node1-cidr" {
  description = "CIDR block for Subnet1"
  type = "string"
  default = "10.1.0.0/28"
}

variable "node2-cidr" {
  description = "CIDR block for Subnet2"
  type = "string"
  default = "10.2.0.0/28"
}

variable "node3-cidr" {
  description = "CIDR block for Subnet3"
  type = "string"
  default = "10.11.0.0/28"
}

variable "node4-cidr" {
  description = "CIDR block for Subnet4"
  type = "string"
  default = "10.12.0.0/28"
}

