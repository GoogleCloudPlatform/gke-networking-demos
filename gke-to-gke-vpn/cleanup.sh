#!/usr/bin/env bash
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

### Deletes all the resources created as part of gke-to-gke-vpn POC.

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

### Delete cluster1 services
if cluster_running "${PROJECT_ID}" "cluster-deployment-cluster1"; then
  gcloud container clusters get-credentials cluster-deployment-cluster1 \
    --zone us-east1-d
  kubectl config set-context "$(kubectl config current-context)" --namespace=default
  kubectl delete -f "${ROOT}"/manifests/lb-svc.yaml --cascade --grace-period 10
  kubectl delete -f "${ROOT}"/manifests/nodeport-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/cluster-ip-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/run-my-nginx.yaml
  kubectl delete -f "${ROOT}"/manifests/ilb-svc.yaml --cascade --grace-period 10
fi

### Delete cluster2 services
if cluster_running "${PROJECT_ID}" "cluster-deployment-cluster2"; then
  gcloud container clusters get-credentials cluster-deployment-cluster2 \
    --zone us-central1-b
  kubectl config set-context "$(kubectl config current-context)" --namespace=default
  kubectl delete -f "${ROOT}"/manifests/lb-svc.yaml --cascade --grace-period 10
  kubectl delete -f "${ROOT}"/manifests/nodeport-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/cluster-ip-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/run-my-nginx.yaml
  kubectl delete -f "${ROOT}"/manifests/ingress-svc.yaml --cascade --grace-period 10
fi

### Delete cluster3 services
if cluster_running "${PROJECT_ID}" "cluster-deployment-cluster3"; then
  gcloud container clusters get-credentials cluster-deployment-cluster3 \
    --zone us-east1-c
  kubectl config set-context "$(kubectl config current-context)" --namespace=default
  kubectl delete -f "${ROOT}"/manifests/lb-svc.yaml --cascade --grace-period 10
  kubectl delete -f "${ROOT}"/manifests/nodeport-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/cluster-ip-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/run-my-nginx.yaml
  kubectl delete -f "${ROOT}"/manifests/ilb-svc.yaml --cascade --grace-period 10
fi

### Delete cluster4 services
if cluster_running "${PROJECT_ID}" "cluster-deployment-cluster4"; then
  gcloud container clusters get-credentials cluster-deployment-cluster4 \
    --zone us-central1-c
  kubectl config set-context "$(kubectl config current-context)" --namespace=default
  kubectl delete -f "${ROOT}"/manifests/lb-svc.yaml --cascade --grace-period 10
  kubectl delete -f "${ROOT}"/manifests/nodeport-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/cluster-ip-svc.yaml
  kubectl delete -f "${ROOT}"/manifests/run-my-nginx.yaml
  kubectl delete -f "${ROOT}"/manifests/ingress-svc.yaml --cascade --grace-period 10
fi

### wait for all service related backends to get deleted.
### Otherwise, deletion of network deployments fails with dependent resources.
if backends_exists "${PROJECT_ID}" "k8s-ig"; then
  echo "Service related backends have been removed"
fi

(cd "$ROOT/gke-to-gke-vpn/terraform" && terraform destroy -auto-approve)
