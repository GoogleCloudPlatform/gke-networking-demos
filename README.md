# Kubernetes Engine Networking


## Introduction

Google cloud networking with Kubernetes Engine clusters can
be complex. Assigning optimal CIDR ranges for the relevant VPC subnets
and the Kubernetes Engine clusters' reserved IP ranges from the start is very important
since VPC subnets are not always easy to resize and the cluster's reserved
IP ranges are immutable. Using the correct method to expose the applications
in the cluster is important as every method was designed for a different
set of use cases.

The demos in the project demonstrate the following best practices:

1. Connecting two GCP networks using VPC peering and Cloud VPN containing two Kubernetes Engine clusters each.
1. Deploying the nginx pods.
1. Exposing the pods using Kubernetes Engine services
1. Validating pod-to-service communication across the Kubernetes Engine clusters within the same region and the different regions.

## Prerequisites

### Tools
1. [Google Cloud SDK version >= 204.0.0](https://cloud.google.com/sdk/docs/downloads-versioned-archives)
2. [kubectl matching the latest GKE version](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
3. bash or bash compatible shell
4. [jq](https://stedolan.github.io/jq/)

#### Install Cloud SDK
The Google Cloud SDK is used to interact with your GCP resources.
[Installation instructions](https://cloud.google.com/sdk/downloads) for multiple platforms are available online.

#### Install kubectl CLI
The kubectl CLI is used to interteract with both Kubernetes Engine and kubernetes in general.
[Installation instructions](https://cloud.google.com/kubernetes-engine/docs/quickstart)
for multiple platforms are available online.

## Directory Structure
1. The [gke-to-gke-peering](gke-to-gke-peering) and [gke-to-gke-vpn](gke-to-gke-vpn) folders each contain a project.
1. README files exist for the above examples; [gke-to-gke-peering/README.md](gke-to-gke-peering/README.md) and [gke-to-gke-vpn/README.md](gke-to-gke-vpn/README.md).
1. The [network](network) folder contains the manifest files and deployment manager templates to setup networks.
1. The [clusters](clusters) folder contains the manifest files and deployment manager templates to create Kubernetes Engine clusters.
1. The [manifests](clusters) folder contains the manifest files to create Kubernetes Engine services.


**This is not an officially supported Google product**
