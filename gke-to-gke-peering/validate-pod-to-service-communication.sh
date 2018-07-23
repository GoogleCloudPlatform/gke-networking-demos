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

### Validate gcp projects
( gcloud projects describe $1 | grep projectNumber >/dev/null 2>&1 ) || \
	{  echo "Project 1 is not valid. Aborting."; exit 1; }

( gcloud projects describe $2 | grep projectNumber >/dev/null 2>&1 ) || \
	{ echo "Project 2 is not valid. Aborting."; exit 1; }

CLUSTER1_ZONE=$( gcloud container clusters list --project $1 \
	| grep "cluster1" | awk '{ print $2 }' )
CLUSTER2_ZONE=$( gcloud container clusters list --project $1 \
	| grep "cluster2" | awk '{ print $2 }' )
CLUSTER3_ZONE=$( gcloud container clusters list --project $2 \
	| grep "cluster3" | awk '{ print $2 }' )
CLUSTER4_ZONE=$( gcloud container clusters list --project $2 \
	| grep "cluster4" | awk '{ print $2 }' )

### use cluster1 context
kubectl config use-context gke_$1_"$CLUSTER1_ZONE"_cluster1-deployment-cluster1

POD_NAME=$( kubectl get pods -o wide | awk 'NR==2 {print $1}' )

echo "----------------------------------------"
echo "curl clusterIP service from cluster1"
SERVICE_IP=$( kubectl get services|grep -w "my-nginx "|awk '{print $3}' )
echo "kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP"
kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP
echo "----------------------------------------"


echo "----------------------------------------"
echo "curl nodeport service from cluster1"
SERVICE_IP=$( kubectl get services|grep -w "my-nginx-nodeport "|awk '{print $3}' )
echo "kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080"
kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080
echo "----------------------------------------"


echo "----------------------------------------"
echo "curl ILB service from cluster1"
SERVICE_IP=$( kubectl get services|grep -w "my-nginx-ilb "|awk '{print $4}' )
echo "kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080"
kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080
echo "----------------------------------------"


echo "----------------------------------------"
echo "curl ILB from cluster3 in same region of peered network"
SERVICE_IP=$( kubectl get services --cluster \
	gke_$2_"$CLUSTER3_ZONE"_cluster3-deployment-cluster3 \
	| grep -w "my-nginx-ilb "| awk '{print $4}' )
echo "kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080"
kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080
echo "----------------------------------------"

echo "----------------------------------------"
echo "curl LB service from cluster1"
SERVICE_IP=$( kubectl get services|grep -w "my-nginx-lb "|awk '{print $4}' )
echo "kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080"
kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080
echo "----------------------------------------"

echo "----------------------------------------"
echo "curl Ingress from cluster1"
SERVICE_IP=$( kubectl get ingress|grep -w "my-nginx-ingress "|awk '{print $3}' )
echo "kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP"
kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP
echo "----------------------------------------"

echo "----------------------------------------"
echo "curl LB service from cluster2 which is in different region on same network"
SERVICE_IP=$( kubectl get services --cluster \
	gke_$1_"$CLUSTER2_ZONE"_cluster2-deployment-cluster2 \
	| grep -w "my-nginx-lb-2 "| awk '{print $4}' )
echo "kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080"
kubectl exec $POD_NAME -c my-test -- curl -s -I $SERVICE_IP:8080
echo "----------------------------------------"
