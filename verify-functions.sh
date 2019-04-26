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
#   status code
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
#   status code
#     0:   the deployment should exist, except that it does not
#     1:   the deployment exists
#     2:   no trace of the deployment left, it can be an indicator of successful clean up earlier
function deployment_exists() {
  local PROJECT="${1}"
  local DEPLOY="${2}"
  local EXISTS
  EXISTS=$(gcloud deployment-manager deployments list --project "${PROJECT}" \
    --filter="name=${DEPLOY} AND operation.status=DONE" --format "value(operation.error.errors)")
  if [[ "${EXISTS}" != "" ]]; then
    if [[ "${EXISTS}" != "[]" ]]; then
      echo "ERROR ${DEPLOY}: ${EXISTS}"
      return 0
    fi
  else  ##  EXISTS = ""  the resource cannot be found at all
    return 2
  fi
  # default exit code, where the resource can be found and there are no operation.error.errors
  return 1
}

# Delete a deployment, including retry logic where necessary
# Globals:
#   None
# Arguments:
#   PROJECT
#   DEPLOY
#   RETRY  - number of retrys, default to 3
# Returns:
#   status code
function deployment_deletes() {
  local PROJECT="${1:-}"
  local DEPLOY="${2:-}"
  local RETRY="${3:-3}"

  while [ "${RETRY}" -gt 0 ]; do
    echo "Trying to delete ${DEPLOY}"
    gcloud deployment-manager deployments delete "${DEPLOY}" --quiet --project "${PROJECT}"
    deployment_exists "${PROJECT}" "${DEPLOY}"
    if [[ "$?" != "2" ]]; then
      echo "failed deleting ${DEPLOY}.  Retrying ..."
      sleep 20
      RETRY=$((RETRY-1))
    else
      break
    fi
  done

  # Fail the deletion if there are still traces of deployment left after multiple attempts of deletion
  deployment_exists "${PROJECT}" "${DEPLOY}"
  if [[ "$?" != "2" ]]; then
    return 1
  fi

  return 0
}

# Check if a given network exists
# Globals:
#   None
# Arguments:
#   PROJECT
#   NETWORK
# Returns:
#   status code
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
#   status code
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
#   status code
#     0:   the network peering exists
#     1:   the network peering does not exist
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

# Delete a network peering, including retry logic where necessary
# Globals:
#   None
# Arguments:
#   PROJECT
#   NETWORK
#   PEERING
#   RETRY  - number of retrys, default to 3
# Returns:
#   status code
function network_peering_deletes() {
  local PROJECT="${1:-}"
  local NETWORK="${2:-}"
  local PEERING="${3:-}"
  local RETRY="${4:-3}"

  while [ "${RETRY}" -gt 0 ]; do
    gcloud compute networks peerings delete "${PEERING}" --network "${NETWORK}" --project "${PROJECT}" --quiet
    network_peering_exists "${PROJECT}" "${NETWORK}"
    if [[ "$?" != "1" ]]; then
      sleep 10
      RETRY=$((RETRY-1))
    else
      break
    fi
  done

  # Fail the deletion if there are still traces of deployment left after multiple attempts of deletion
  if ! network_peering_exists "${PROJECT}" "${NETWORK}"
  then
    return 1
  fi

  return 0
}


# Verify cidr range
# Globals:
#   None
# Arguments:
#   PROJECT
#   SUBNET
#   RANGE
# Returns:
#   status code
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
#   status code
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
#   SERVICE
#   RETRY_COUNT  - Number of times to retry
#   INTERVAL     - Amount of time to sleep between retries
#   NAMESPACE    - k8s namespace the service lives in
# Returns:
#   status code
function access_service () {
  local PROJECT="${1}"
  local CLUSTER="${2}"
  local SERVICE="${3}"
  local RETRY_COUNT="15"
  local SLEEP="15"
  local NAMESPACE="default"
  local SERVICE_IP

  for ((i=0; i<"${RETRY_COUNT}"; i++)); do
    SERVICE_IP=$(kubectl get -n "${NAMESPACE}" --cluster "${CLUSTER}" \
      service "${SERVICE}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ "${SERVICE_IP}" == "" ] ; then
      echo "Attempt $((i + 1)): IP not yet allocated for service ${SERVICE}" >&1
    else
      echo "$SERVICE_IP has been allocated for service ${SERVICE} in ${CLUSTER}" >&1
      return 0
    fi
    sleep "${SLEEP}"
  done
  echo "Timed out waiting for service ${SERVICE} to be allocated an IP address." >&1
  return 1
}

# Check if service backends exist
# Globals:
#   None
# Arguments:
#   PROJECT
#   NAME
#   RETRY_COUNT  - Number of times to retry
#   INTERVAL     - Amount of time to sleep between retries
#   NAMESPACE    - k8s namespace the service lives in
# Returns:
#   status code
function backends_exists () {
  local PROJECT="${1}"
  local NAME="${2}"
  local RETRY_COUNT="50"
  local SLEEP="10"
  local BACKEND

  for ((i=0; i<"${RETRY_COUNT}"; i++)); do
    BACKEND=$(gcloud compute backend-services list --project "$PROJECT" \
      --format "value(backends.group)" | grep "${NAME}")
    if [ "${BACKEND}" == "" ] ; then
      return 0
    else
      echo "Attempt $((i + 1)): Checking if service backends are removed" >&1
    fi
    sleep "${SLEEP}"
  done
  echo "Timed out waiting for service backends to be removed." >&1
  return 1
}
