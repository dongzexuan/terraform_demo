#!/bin/bash

#  Script used to create the maplarge kubernetes cluster.
#  You should execute the following command prior to running this script (or similar for PROD)
#   gcloud container clusters get-credentials maplarge --zone us-central1-a --project aaet-geoscience-dev
#

cd /workspaces/lithos-infrastructure/MapLargeCluster
terraform workspace select development
terraform apply -var 'GCP_PROJECT=aaet-geoscience-dev' -var 'GCP_REGION=us-central1-a'