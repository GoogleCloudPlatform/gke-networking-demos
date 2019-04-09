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

# bash "strict-mode", fail immediately if there is a problem
set -o nounset
set -o pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT="$(dirname "${dir}")"

#shellcheck disable=SC1090
source "${ROOT}/verify-functions.sh"

PROJECT_ID=$(gcloud config get-value project)
if [ -z "${PROJECT_ID}" ]
  then echo >&2 "I require default project is set but it's not. Aborting."; exit 1;
fi

### Obtain Cluster Zone
CLUSTER1_ZONE=$(gcloud container clusters list \
  --filter="name=cluster-deployment-cluster1" --format "value(zone)")
CLUSTER2_ZONE=$(gcloud container clusters list \
  --filter="name=cluster-deployment-cluster2" --format "value(zone)")
CLUSTER3_ZONE=$(gcloud container clusters list \
  --filter="name=cluster-deployment-cluster3" --format "value(zone)")
CLUSTER4_ZONE=$(gcloud container clusters list \
  --filter="name=cluster-deployment-cluster4" --format "value(zone)")

CLUSTER1_CONTEXT="gke_${PROJECT_ID}_${CLUSTER1_ZONE}_cluster-deployment-cluster1"
CLUSTER2_CONTEXT="gke_${PROJECT_ID}_${CLUSTER2_ZONE}_cluster-deployment-cluster2"
CLUSTER3_CONTEXT="gke_${PROJECT_ID}_${CLUSTER3_ZONE}_cluster-deployment-cluster3"
CLUSTER4_CONTEXT="gke_${PROJECT_ID}_${CLUSTER4_ZONE}_cluster-deployment-cluster4"

### Ensure that the Networks exists
if ! network_exists "${PROJECT_ID}" "network1" || \
  ! network_exists "${PROJECT_ID}" "network2"; then
  echo "Network is missing"
  echo "Terminating..."
  exit 1
fi

### Ensure that the Subnet range is correct
if ! verify_cidr_range "${PROJECT_ID}" "subnet1-us-east1" "10.1.0.0/28"; then
  echo "Subnet ip range is incorrect"
  echo "Terminating..."
  exit 1
fi

### Ensure that the Subnet range is correct
if ! verify_cidr_range "${PROJECT_ID}" "subnet2-us-central1" "10.2.0.0/28"; then
  echo "Subnet ip range is incorrect"
  echo "Terminating..."
  exit 1
fi

### Ensure that the Subnet range is correct
if ! verify_cidr_range "${PROJECT_ID}" "subnet3-us-east1" "10.11.0.0/28"; then
  echo "Subnet ip range is incorrect"
  echo "Terminating..."
  exit 1
fi

### Ensure that the Subnet range is correct
if ! verify_cidr_range "${PROJECT_ID}" "subnet4-us-central1" "10.12.0.0/28"; then
  echo "Subnet ip range is incorrect"
  echo "Terminating..."
  exit 1
fi

### Ensure that VPC peering exists
if ! network_peering_exists "${PROJECT_ID}" "network1"; then
    echo "Peering does not exist"
    echo "Terminating..."
    exit 1
fi

if ! network_peering_exists "${PROJECT_ID}" "network2"; then
    echo "Peering does not exist"
    echo "Terminating..."
    exit 1
fi

### Ensure that the clusters are running
for (( c=1; c<=4; c++ ))
do
  if ! cluster_running "${PROJECT_ID}" "cluster-deployment-cluster$c"; then
    echo "cluster$c is missing or is not running"
    echo "Terminating..."
    exit 1
  fi
done

### Check external nginx service ips for cluster1
if ! access_service "${PROJECT_ID}" "${CLUSTER1_CONTEXT}" "my-nginx-lb"; then
  echo "Service ip is not available"
  echo "Terminating..."
  exit 1
fi

### Check internal nginx service ips for cluster1
if ! access_service "${PROJECT_ID}" "${CLUSTER1_CONTEXT}" "my-nginx-ilb"; then
  echo "Service ip is not available"
  echo "Terminating..."
  exit 1
fi

### Check external nginx service ips for cluster2
if ! access_service "${PROJECT_ID}" "${CLUSTER2_CONTEXT}" "my-nginx-lb"; then
  echo "Service ip is not available"
  echo "Terminating..."
  exit 1
fi

### Check external nginx service ips for cluster3
if ! access_service "${PROJECT_ID}" "${CLUSTER3_CONTEXT}" "my-nginx-lb"; then
  echo "Service ip is not available"
  echo "Terminating..."
  exit 1
fi

### Check internal nginx service ips for cluster3
if ! access_service "${PROJECT_ID}" "${CLUSTER3_CONTEXT}" "my-nginx-ilb"; then
  echo "Service ip is not available"
  echo "Terminating..."
  exit 1
fi

### Check external nginx service ips for cluster4
if ! access_service "${PROJECT_ID}" "${CLUSTER4_CONTEXT}" "my-nginx-lb"; then
  echo "Service ip is not available"
  echo "Terminating..."
  exit 1
fi
