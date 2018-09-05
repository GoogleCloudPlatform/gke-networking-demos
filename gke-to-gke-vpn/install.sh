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
ROOT="$(dirname "$dir")"

command -v gcloud >/dev/null 2>&1 || \
	{ echo >&2 "I require gcloud but it's not installed.  Aborting.";exit 1; }

command -v kubectl >/dev/null 2>&1 || \
  	{ echo >&2 "I require kubectl but it's not installed.  Aborting."; exit 1; }

### Obtain current active PROJECT_ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]
	then echo >&2 "I require default project is set but it's not.  Aborting."; exit 1;
fi

### enable required service apis in each project
gcloud services enable \
    compute.googleapis.com \
	deploymentmanager.googleapis.com

### create networks and subnets
gcloud deployment-manager deployments create network1-deployment \
	--config "$ROOT"/network/network1.yaml

gcloud deployment-manager deployments create network2-deployment \
	--config "$ROOT"/network/network2.yaml

### create clusters
gcloud deployment-manager deployments create cluster1-deployment \
	--config "$ROOT"/clusters/cluster1.yaml

gcloud deployment-manager deployments create cluster2-deployment \
	--config "$ROOT"/clusters/cluster2.yaml

gcloud deployment-manager deployments create cluster3-deployment \
	--config "$ROOT"/clusters/cluster3.yaml
gcloud deployment-manager deployments create cluster4-deployment \
	--config "$ROOT"/clusters/cluster4.yaml

### Create static ip for VPN connections
gcloud deployment-manager deployments create static-ip-deployment1 \
	--template static-ip.jinja \
	--properties "name:vpn1-ip,region:us-west1,network:network1"

gcloud deployment-manager deployments create static-ip-deployment2 \
	--template static-ip.jinja \
	--properties "name:vpn2-ip,region:us-east1,network:network1"

gcloud deployment-manager deployments create static-ip-deployment3 \
	--template static-ip.jinja \
	--properties "name:vpn3-ip,region:us-west1,network:network2"

gcloud deployment-manager deployments create static-ip-deployment4 \
	--template static-ip.jinja \
	--properties "name:vpn4-ip,region:us-east1,network:network2"

#Get static VPN IP addresses
VPN1_IP=$( gcloud compute addresses list | grep vpn1 \
	| awk '{ print $3 }' )
VPN2_IP=$( gcloud compute addresses list | grep vpn2 \
	| awk '{ print $3 }' )
VPN3_IP=$( gcloud compute addresses list | grep vpn3 \
	| awk '{ print $3 }' )
VPN4_IP=$( gcloud compute addresses list | grep vpn4 \
	| awk '{ print $3 }' )

### Create VPN connection for network1 and network2 in us-east1 &
### us-west1 regions
gcloud deployment-manager deployments create vpn1-deployment \
	--template vpn-custom-subnet.jinja \
	--properties "region:us-west1,network:projects/$PROJECT_ID/global/networks/network1,\
vpn-ip:$VPN1_IP,peerIp:$VPN3_IP,sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.11.0.0/28,clusterCIDR:10.128.0.0/19,\
serviceCIDR:10.228.0.0/20"

gcloud deployment-manager deployments create vpn2-deployment \
	--template vpn-custom-subnet.jinja \
	--properties "region:us-east1,network:projects/$PROJECT_ID/global/networks/network1,\
vpn-ip:$VPN2_IP,peerIp:$VPN4_IP,sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.12.0.0/28,clusterCIDR:10.138.0.0/19,\
serviceCIDR:10.238.0.0/20"

gcloud deployment-manager deployments create vpn3-deployment \
	--template vpn-custom-subnet.jinja \
	--properties "region:us-west1,network:projects/$PROJECT_ID/global/networks/network2,\
vpn-ip:$VPN3_IP,peerIp:$VPN1_IP,sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.1.0.0/28,clusterCIDR:10.108.0.0/19,\
serviceCIDR:10.208.0.0/20"

gcloud deployment-manager deployments create vpn4-deployment \
	--template vpn-custom-subnet.jinja \
	--properties "region:us-east1,network:projects/$PROJECT_ID/global/networks/network2,\
vpn-ip:$VPN4_IP,peerIp:$VPN2_IP,sharedSecret:gke-to-gke-vpn,\
nodeCIDR:10.2.0.0/28,clusterCIDR:10.118.0.0/19,\
serviceCIDR:10.218.0.0/20"

### Fetch cluster1 credentials, deploy nginx pods in cluster1 and create
### services
gcloud container clusters get-credentials cluster1-deployment-cluster1 \
	--zone us-west1-b
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc.yaml
kubectl create -f "$ROOT"/manifests/lb-svc.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc.yaml


### Fetch cluster2 credentials, deploy nginx pods in cluster2 and create
### services
gcloud container clusters get-credentials cluster2-deployment-cluster2 \
	--zone us-east1-b
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc1.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc1.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc1.yaml
kubectl create -f "$ROOT"/manifests/lb-svc1.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc1.yaml


### Fetch cluster3 credentials, deploy nginx pods in cluster3 and create
### services
gcloud container clusters get-credentials cluster3-deployment-cluster3 \
	--zone us-west1-c
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc.yaml
kubectl create -f "$ROOT"/manifests/lb-svc.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc.yaml


### Fetch cluster4 credentials, deploy nginx pods in cluster4 and create
### services
gcloud container clusters get-credentials cluster4-deployment-cluster4 \
	--zone us-east1-c
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc1.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc1.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc1.yaml
kubectl create -f "$ROOT"/manifests/lb-svc1.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc1.yaml
