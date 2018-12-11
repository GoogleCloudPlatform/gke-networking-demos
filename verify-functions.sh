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

# Library of functions used by the validate the project

# Check if a resource quota is met
# Globals:
#   None
# Arguments:
#   PROJECT
#   METRICS
#   QUOTA
# Returns:
#   1
function meets_quota() {
  local PROJECT="$1"
  local METRIC="$2"
  local QUOTA="$3"
  local LIMIT
  LIMIT=$(gcloud compute project-info describe --project "$PROJECT" \
    --format=json | jq --arg METRIC "$METRIC" '.quotas[] | select(.metric==$METRIC).limit')
  if [[ "${LIMIT}" -ge "$QUOTA" ]]; then
    return 0
  fi
    echo ""
    echo "$METRIC quota of $QUOTA is not met"
    echo ""
  return 1
}

# Check if a given deployment exists
# Globals:
#   None
# Arguments:
#   PROJECT
#   DEPLOY
# Returns:
#   1
function deployment_exists() {
  local PROJECT="${1}"
  local DEPLOY="${2}"
  local EXISTS
  EXISTS=$(gcloud deployment-manager deployments list --project "${PROJECT}" \
    --filter="name=${DEPLOY} AND operation.status=DONE" --format "value(operation.error.errors)")
  if [[ "${EXISTS}" != "" ]]; then
    echo "${DEPLOY} deployment exists"
    if [[ "${EXISTS}" != "[]" ]]; then
      echo "ERROR ${DEPLOY}: ${EXISTS}"
    fi
    return 0
  fi
  return 1
}

# Check if a given network exists
# Globals:
#   None
# Arguments:
#   PROJECT
#   NETWORK
# Returns:
#   1
function network_exists() {
  local PROJECT="${1}"
  local NETWORK="${2}"
  local EXISTS
  EXISTS=$(gcloud compute networks list --project "${PROJECT}" \
    --filter="name=${NETWORK}" --format "value(name)")
  if [[ "${EXISTS}" != "" ]]; then
    echo "${NETWORK} network exists"
    return 0
  fi
  return 1
}

# Check if a given vpn exists
# Globals:
#   None
# Arguments:
#   PROJECT
#   VPN
# Returns:
#   1
function vpn_exists() {
  local PROJECT="${1}"
  local VPN="${2}"
  local EXISTS
  EXISTS=$(gcloud compute vpn-tunnels list --project "${PROJECT}" \
    --filter="name=${VPN} and status=ESTABLISHED" --format "value(name)")
  if [[ "${EXISTS}" != "" ]]; then
    echo "${VPN} vpn exists"
    return 0
  fi
  return 1
}

# Check if a given network peering exists
# Globals:
#   None
# Arguments:
#   PROJECT
#   NETWORK
# Returns:
#   1
function network_peering_exists() {
  local PROJECT="${1}"
  local NETWORK="${2}"
  local EXISTS
  EXISTS=$(gcloud compute networks peerings list --project "${PROJECT}" \
    --filter="name=${NETWORK}" --format "value(name)")
  if [[ "${EXISTS}" != "" ]]; then
    echo "${NETWORK} peering exists"
    return 0
  fi
  return 1
}

# Verify cidr range
# Globals:
#   None
# Arguments:
#   PROJECT
#   SUBNET
#   RANGE
# Returns:
#   1
function verify_cidr_range() {
  local PROJECT="${1}"
  local SUBNET="${2}"
  local CIDR="${3}"
  local RANGE
  RANGE=$(gcloud compute networks subnets list --project "${PROJECT}" \
    --filter="name=${SUBNET}" --format "value(RANGE)")
  if [[ "${RANGE}" == "${CIDR}" ]]; then
    echo "Subnet ${SUBNET} has the ip range ${RANGE}"
    return 0
  fi
  return 1
}

# Check if a cluster exists
# Globals:
#   None
# Arguments:
#   PROJECT
#   CLUSTER
# Returns:
#   None
function cluster_running() {
  local PROJECT="${1}"
  local CLUSTER="${2}"
  local RUNNING
  RUNNING=$(gcloud container clusters list  --project "${PROJECT}" \
    --filter="name=${CLUSTER} AND status:RUNNING" --format "value(name)")
  if [[ "${RUNNING}" == "${CLUSTER}" ]]; then
    echo "Cluster ${CLUSTER} is running"
    return 0
  fi
  return 1
}


# Check if service ip is available
# Globals:
#   None
# Arguments:
#   PROJECT
#   CLUSTER
#   NAME
# Returns:
#   None
function access_service() {
  local PROJECT="${1}"
  local CLUSTER="${2}"
  local NAME="${3}"
  local SERVICE_IP
  SERVICE_IP=$( kubectl get services --cluster "${CLUSTER}" | grep -w "${NAME}" \
    | awk '{print $4}' )
  echo "Checking ${NAME} service ip for ${CLUSTER}"
  if [ ! -z "${SERVICE_IP}" ]; then
    echo "curl -s -I ${SERVICE_IP}:8080"
  fi
  curl -s -I "${SERVICE_IP}":8080
  return $?
}
