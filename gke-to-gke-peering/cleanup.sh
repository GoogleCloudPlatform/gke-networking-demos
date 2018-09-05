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

### Deletes all the resources created as part of gke-to-gke-peering POC.

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT="$(dirname "$dir")"

command -v gcloud >/dev/null 2>&1 || \
  { echo >&2 "I require gcloud but it's not installed.  Aborting.";exit 1; }

command -v kubectl >/dev/null 2>&1 || \
  { echo >&2 "I require kubectl but it's not installed.  Aborting."; exit 1; }

### Delete cluster1 services
gcloud container clusters get-credentials cluster1-deployment-cluster1 \
  --zone us-west1-b
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl delete -f "$ROOT"/manifests/ingress-svc.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/lb-svc.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/ilb-svc.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/nodeport-svc.yaml
kubectl delete -f "$ROOT"/manifests/cluster-ip-svc.yaml
kubectl delete -f "$ROOT"/manifests/run-my-nginx.yaml

### Delete cluster2 services
gcloud container clusters get-credentials cluster2-deployment-cluster2 \
  --zone us-east1-b
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl delete -f "$ROOT"/manifests/ingress-svc1.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/lb-svc1.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/ilb-svc1.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/nodeport-svc1.yaml
kubectl delete -f "$ROOT"/manifests/cluster-ip-svc1.yaml
kubectl delete -f "$ROOT"/manifests/run-my-nginx.yaml

### Delete cluster3 services
gcloud container clusters get-credentials cluster3-deployment-cluster3 \
  --zone us-west1-c
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl delete -f "$ROOT"/manifests/ingress-svc.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/lb-svc.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/ilb-svc.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/nodeport-svc.yaml
kubectl delete -f "$ROOT"/manifests/cluster-ip-svc.yaml
kubectl delete -f "$ROOT"/manifests/run-my-nginx.yaml

### Delete cluster4 services
gcloud container clusters get-credentials cluster4-deployment-cluster4 \
  --zone us-east1-c
kubectl config set-context "$(kubectl config current-context)" --namespace=default
kubectl delete -f "$ROOT"/manifests/ingress-svc1.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/lb-svc1.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/ilb-svc1.yaml --cascade --grace-period 10
kubectl delete -f "$ROOT"/manifests/nodeport-svc1.yaml
kubectl delete -f "$ROOT"/manifests/cluster-ip-svc1.yaml
kubectl delete -f "$ROOT"/manifests/run-my-nginx.yaml

### wait for all service related backends to get deleted.
### Otherwise, deletion of network deployments fails with dependent resources.
sleep 120

### Delete clusters
gcloud deployment-manager deployments delete cluster1-deployment \
  --quiet
gcloud deployment-manager deployments delete cluster2-deployment \
  --quiet
gcloud deployment-manager deployments delete cluster3-deployment \
  --quiet
gcloud deployment-manager deployments delete cluster4-deployment \
  --quiet

### Delete VPC peering connections
gcloud compute networks peerings delete peer-network1-to-network2  \
  --network network1 --quiet
gcloud compute networks peerings delete peer-network2-to-network1  \
  --network network2 --quiet

### Delete network
gcloud deployment-manager deployments delete network1-deployment \
  --quiet
gcloud deployment-manager deployments delete network2-deployment \
  --quiet
