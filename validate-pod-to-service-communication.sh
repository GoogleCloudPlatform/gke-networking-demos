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

### Executes commands to verify pod-to-service communication from test container
### of the pods in cluster1.
### cluster zones can be modified as needed.

### Obtain current active PROJECT_ID
PROJECT_ID=$(gcloud config get-value project)

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

### use cluster1 context
kubectl config use-context "${CLUSTER1_CONTEXT}"
kubectl config set-context "$(kubectl config current-context)" --namespace=default

POD_NAME=$(kubectl get pods -l run=my-nginx -o jsonpath='{.items[].metadata.name}')

### Within cluster tests
echo "----------------------------------------"
echo "Testing: cluster1 -> cluster1 clusterIP service"
SERVICE_IP=$(kubectl get services --field-selector metadata.name=my-nginx \
  -o jsonpath='{.items[].spec.clusterIP}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}"
echo "----------------------------------------"

echo "----------------------------------------"
echo "Testing: cluster1 -> cluster1 nodeport service"
SERVICE_IP=$(kubectl get services --field-selector metadata.name=my-nginx-nodeport \
  -o jsonpath='{.items[].spec.clusterIP}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}:8080"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}":8080
echo "----------------------------------------"

### Internal Load Balancer tests
echo "----------------------------------------"
echo "Testing: cluster1 -> cluster1 ILB service"
SERVICE_IP=$(kubectl get services --field-selector metadata.name=my-nginx-ilb \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}:8080"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}":8080
echo "----------------------------------------"

echo "----------------------------------------"
echo "Testing: cluster1 -> cluster3 ILB (same region)"
SERVICE_IP=$( kubectl get services --cluster "${CLUSTER3_CONTEXT}" \
  --field-selector metadata.name=my-nginx-ilb \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}:8080"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}":8080
echo "----------------------------------------"

#### Ingress tests
echo "----------------------------------------"
echo "Testing: cluster1 -> cluster2 ingress service"
SERVICE_IP=$(kubectl get ingress --cluster "${CLUSTER2_CONTEXT}" \
  --field-selector metadata.name=my-nginx-ingress \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}"
echo "----------------------------------------"

echo "----------------------------------------"
echo "Testing: cluster1 -> cluster4 ingress service"
SERVICE_IP=$(kubectl get ingress --cluster "${CLUSTER4_CONTEXT}" \
  --field-selector metadata.name=my-nginx-ingress \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}"
echo "----------------------------------------"

#### Load Balancer tests
echo "----------------------------------------"
echo "Testing: cluster1 -> cluster1 LB service"
SERVICE_IP=$(kubectl get services --field-selector metadata.name=my-nginx-lb \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}:8080"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}":8080
echo "----------------------------------------"

echo "----------------------------------------"
echo "Testing: cluster1 -> cluster2 LB service (cross region)"
SERVICE_IP=$( kubectl get services --cluster "${CLUSTER2_CONTEXT}" \
  --field-selector metadata.name=my-nginx-lb \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}:8080"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}":8080
echo "----------------------------------------"

echo "----------------------------------------"
echo "Testing: cluster1 -> cluster3 LB service"
SERVICE_IP=$( kubectl get services --cluster "${CLUSTER3_CONTEXT}" \
  --field-selector metadata.name=my-nginx-lb \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}:8080"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}":8080
echo "----------------------------------------"

echo "----------------------------------------"
echo "Testing: cluster1 -> cluster4 LB service (cross region)"
SERVICE_IP=$( kubectl get services --cluster "${CLUSTER4_CONTEXT}" \
  --field-selector metadata.name=my-nginx-lb \
  -o jsonpath='{.items[].status.loadBalancer.ingress[].ip}')
echo "kubectl exec ${POD_NAME} -c my-nginx -- curl -s -I ${SERVICE_IP}:8080"
kubectl exec "${POD_NAME}" -c my-nginx -- curl -s -I "${SERVICE_IP}":8080
echo "----------------------------------------"
