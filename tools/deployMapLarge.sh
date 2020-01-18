#!/bin/bash
#
#  Script used to redeploy the maplarge software into kubernetes.  Often used when MapLarge updates
#     their software.
#  You should execute the following command prior to running this script (or similar for PROD)
#   gcloud container clusters get-credentials maplarge --zone us-central1-a --project aaet-geoscience-dev
#
gcloud container clusters get-credentials maplarge --zone us-central1-a --project aaet-geoscience-dev
kubectl delete statefulset maplarge-master-ss
kubectl create -f /workspaces/lithos-infrastructure/MapLargeCluster/maplarge-master-ss.yaml