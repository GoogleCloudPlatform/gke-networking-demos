#!/bin/bash -e

# Copyright 2018 Google LLC
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

### Creates GCP/GKE resources for GKE-to-GKE-communication-through-VPN
### Refer to https://cloud.google.com/sdk/gcloud/ for usage of gcloud
### Deployment manager templates, gcloud and kubectl commands are used.

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT="$(dirname "${dir}")"

#shellcheck disable=SC1090
source "${ROOT}/verify-functions.sh"

command -v gcloud >/dev/null 2>&1 || \
  { echo >&2 "I require gcloud but it's not installed. Aborting.";exit 1; }

command -v kubectl >/dev/null 2>&1 || \
  { echo >&2 "I require kubectl but it's not installed. Aborting."; exit 1; }

### Obtain current active PROJECT_ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "${PROJECT_ID}" ]
  then echo >&2 "I require default project is set but it's not. Aborting."; exit 1;
fi

### Ensure that the Forwarding rules quota is met
if ! meets_quota "${PROJECT_ID}" "FORWARDING_RULES" 8; then
  echo "Refer to https://cloud.google.com/compute/quotas"
  echo "Terminating..."
  exit 1
fi

### Ensure that the In-use IP addresses global quota is met
if ! meets_quota "${PROJECT_ID}" "IN_USE_ADDRESSES" 6; then
  echo "Refer to https://cloud.google.com/compute/quotas"
  echo "Terminating..."
  exit 1
fi

### Ensure that the Backend services quota is met
if ! meets_quota "${PROJECT_ID}" "BACKEND_SERVICES" 4; then
  echo "Refer to https://cloud.google.com/compute/quotas"
  echo "Terminating..."
  exit 1
fi

### Ensure that the Firewall rules quota is met
if ! meets_quota "${PROJECT_ID}" "FIREWALLS" 42; then
  echo "Refer to https://cloud.google.com/compute/quotas"
  echo "Terminating..."
  exit 1
fi

### enable required service apis in the project
gcloud services enable \
  compute.googleapis.com \
  deploymentmanager.googleapis.com

### create networks and subnets
if ! deployment_exists "${PROJECT_ID}" "network-deployment"; then
  gcloud deployment-manager deployments create network-deployment \
    --config "${ROOT}"/network/network.yaml
fi

### create clusters
if ! deployment_exists "${PROJECT_ID}" "cluster-deployment"; then
  gcloud deployment-manager deployments create cluster-deployment \
    --config "${ROOT}"/clusters/cluster.yaml
fi

### Create static ip for VPN connections
if ! deployment_exists "${PROJECT_ID}" "static-ip-deployment"; then
  gcloud deployment-manager deployments create static-ip-deployment \
    --config "${ROOT}"/network/static-ip.yaml
fi

#Get static VPN IP addresses
VPN1_IP=$(gcloud compute addresses list --filter="name=vpn1-ip-address" \
  --format "value(address)")
VPN2_IP=$(gcloud compute addresses list --filter="name=vpn2-ip-address" \
  --format "value(address)")
VPN3_IP=$(gcloud compute addresses list --filter="name=vpn3-ip-address" \
  --format "value(address)")
VPN4_IP=$(gcloud compute addresses list --filter="name=vpn4-ip-address" \
  --format "value(address)")

### Create VPN connection for network1 and network2 in us-central1 &
### us-west1 regions
if ! deployment_exists "${PROJECT_ID}" "vpn1-deployment"; then
  gcloud deployment-manager deployments create vpn1-deployment \
    --template vpn-custom-subnet.jinja \
    --properties "region:us-west1,network:projects/${PROJECT_ID}/global/networks/network1,\
vpn-ip:${VPN1_IP},peerIp:${VPN3_IP},sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.11.0.0/28,clusterCIDR:10.128.0.0/19,serviceCIDR:10.228.0.0/20"
fi

if ! deployment_exists "${PROJECT_ID}" "vpn2-deployment"; then
  gcloud deployment-manager deployments create vpn2-deployment \
    --template vpn-custom-subnet.jinja \
    --properties "region:us-central1,network:projects/${PROJECT_ID}/global/networks/network1,\
vpn-ip:${VPN2_IP},peerIp:${VPN4_IP},sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.12.0.0/28,clusterCIDR:10.138.0.0/19,serviceCIDR:10.238.0.0/20"
fi

if ! deployment_exists "${PROJECT_ID}" "vpn3-deployment"; then
  gcloud deployment-manager deployments create vpn3-deployment \
    --template vpn-custom-subnet.jinja \
    --properties "region:us-west1,network:projects/${PROJECT_ID}/global/networks/network2,\
vpn-ip:${VPN3_IP},peerIp:${VPN1_IP},sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.1.0.0/28,clusterCIDR:10.108.0.0/19,serviceCIDR:10.208.0.0/20"
fi

if ! deployment_exists "${PROJECT_ID}" "vpn4-deployment"; then
  gcloud deployment-manager deployments create vpn4-deployment \
   --template vpn-custom-subnet.jinja \
   --properties "region:us-central1,network:projects/${PROJECT_ID}/global/networks/network2,\
vpn-ip:${VPN4_IP},peerIp:${VPN2_IP},sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.2.0.0/28,clusterCIDR:10.118.0.0/19,serviceCIDR:10.218.0.0/20"
fi

### Fetch cluster1 credentials, deploy nginx pods in cluster1 and create services
gcloud container clusters get-credentials cluster-deployment-cluster1 \
  --zone us-west1-b
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl apply -f "${ROOT}"/manifests/run-my-nginx.yaml
kubectl apply -f "${ROOT}"/manifests/cluster-ip-svc.yaml
kubectl apply -f "${ROOT}"/manifests/nodeport-svc.yaml
kubectl apply -f "${ROOT}"/manifests/lb-svc.yaml
kubectl apply -f "${ROOT}"/manifests/ilb-svc.yaml

### Fetch cluster2 credentials, deploy nginx pods in cluster2 and create services
gcloud container clusters get-credentials cluster-deployment-cluster2 \
  --zone us-central1-b
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl apply -f "${ROOT}"/manifests/run-my-nginx.yaml
kubectl apply -f "${ROOT}"/manifests/cluster-ip-svc.yaml
kubectl apply -f "${ROOT}"/manifests/nodeport-svc.yaml
kubectl apply -f "${ROOT}"/manifests/lb-svc.yaml
kubectl apply -f "${ROOT}"/manifests/ingress-svc.yaml

### Fetch cluster3 credentials, deploy nginx pods in cluster3 and create services
gcloud container clusters get-credentials cluster-deployment-cluster3 \
  --zone us-west1-c
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl apply -f "${ROOT}"/manifests/run-my-nginx.yaml
kubectl apply -f "${ROOT}"/manifests/cluster-ip-svc.yaml
kubectl apply -f "${ROOT}"/manifests/nodeport-svc.yaml
kubectl apply -f "${ROOT}"/manifests/lb-svc.yaml
kubectl apply -f "${ROOT}"/manifests/ilb-svc.yaml

### Fetch cluster4 credentials, deploy nginx pods in cluster4 and create services
gcloud container clusters get-credentials cluster-deployment-cluster4 \
  --zone us-central1-c
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl apply -f "${ROOT}"/manifests/run-my-nginx.yaml
kubectl apply -f "${ROOT}"/manifests/cluster-ip-svc.yaml
kubectl apply -f "${ROOT}"/manifests/nodeport-svc.yaml
kubectl apply -f "${ROOT}"/manifests/lb-svc.yaml
kubectl apply -f "${ROOT}"/manifests/ingress-svc.yaml
