#!/bin/bash
#
#  Script used to replicate the maplarge software to GCP.  Often followed by the redploy.sh script
#  to update the cluster

# You must login using a docker hub account that has been given access to this repository
TAG_NAME=ubuntu-xenial-4.5.0-3.2.0.20190906222515-dev-MapLarge
docker pull maplarge/apc:${TAG_NAME}
docker tag maplarge/apc:${TAG_NAME} gcr.io/aaet-geoscience-dev/maplarge/apc:${TAG_NAME}
docker push gcr.io/aaet-geoscience-dev/maplarge/apc:${TAG_NAME}
