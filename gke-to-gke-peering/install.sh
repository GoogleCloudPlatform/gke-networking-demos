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

### Creates GCP/GKE resources for GKE-to-GKE-communication-through-VPC-Peering
### demo.
### Refer to https://cloud.google.com/sdk/gcloud/ for usage of gcloud
### Deployment manager templates, gcloud and kubectl commands are used.

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT="$(dirname "$dir")"

command -v gcloud >/dev/null 2>&1 || \
  { echo >&2 "I require gcloud but it's not installed.  Aborting.";\
  exit 1; }

command -v kubectl >/dev/null 2>&1 || \
  { echo >&2 "I require kubectl but it's not installed.  Aborting."; \
  exit 1; }

PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]
  then echo >&2 "I require default project is set but it's not.  Aborting."; exit 1;
fi

### enable required service apis in the project
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

### create VPC peering connections between network1 & network2
gcloud compute networks peerings create peer-network1-to-network2 \
  --network network1 --peer-network network2 --auto-create-routes

gcloud compute networks peerings create peer-network2-to-network1 \
  --network network2 --peer-network network1 --auto-create-routes

### Fetch cluster1 credentials, deploy nginx pods in cluster1 and create services
gcloud container clusters get-credentials cluster1-deployment-cluster1 \
  --zone us-west1-b
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc.yaml
kubectl create -f "$ROOT"/manifests/lb-svc.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc.yaml

## Fetch cluster2 credentials, deploy nginx pods in cluster2 and create services
gcloud container clusters get-credentials cluster2-deployment-cluster2 \
  --zone us-east1-b
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc1.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc1.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc1.yaml
kubectl create -f "$ROOT"/manifests/lb-svc1.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc1.yaml

## Fetch cluster3 credentials, deploy nginx pods in cluster3 and create services
gcloud container clusters get-credentials cluster3-deployment-cluster3 \
  --zone us-west1-c
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc.yaml
kubectl create -f "$ROOT"/manifests/lb-svc.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc.yaml

## Fetch cluster4 credentials, deploy nginx pods in cluster4 and create services
gcloud container clusters get-credentials cluster4-deployment-cluster4 \
  --zone us-east1-c
kubectl create -f "$ROOT"/manifests/run-my-nginx.yaml
kubectl create -f "$ROOT"/manifests/cluster-ip-svc1.yaml
kubectl create -f "$ROOT"/manifests/nodeport-svc1.yaml
kubectl create -f "$ROOT"/manifests/ilb-svc1.yaml
kubectl create -f "$ROOT"/manifests/lb-svc1.yaml
kubectl create -f "$ROOT"/manifests/ingress-svc1.yaml
