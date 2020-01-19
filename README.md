# Lithos Infrastructure Environment
Tools and documentation for managing Lithos Infrastructure

![Illustration of architecture diagram for Lithos](https://github.com/dongzexuan/terraform_demo/blob/master/illustration.png)

## Development Environment
### Overview
This environment provides the everything necessary to code/test/debug and prepare for release the Lithos Environment.

## Composer Architecture
### Composer Deployment Architecture
#### Creation
1) Create the Cloud Composer environment for Statlas and LogQC
    ```bash
    # Install Composer
    $ gcloud composer environments create lithos --project aaet-geoscience-prod --location us-central1 --zone us-central1-a --python-version 3 --machine-type n1-standard-1 --node-count 3
    # Add 'numpy' pypi package
    $ gcloud composer environments update lithos --project aaet-geoscience-prod --location us-central1  --update-pypi-package numpy 
    ```


## MapLarge GKE Architecture
### MapLarge GKE Deployment Architecture
#### Creation
1) Create the Kubernetes Cluster.

    Execute apply_teraform_<dev/prod>.sh.  This will set the terraform configuration to be the development environment, then will apply the configuration to the aaet-geoscience-<dev/prod> GCP Project
    ```bash
    $ apply_terraform_<dev/prod>.sh 
    google_container_cluster.primary: Refreshing state... [id=maplarge]
    google_container_node_pool.primary_preemptible_nodes: Refreshing state... [id=us-central1-a/maplarge/node-pool]

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:
    .
    .
    .
    Plan: 1 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions in workspace "development"?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value:
    ```
1) Create the static IP address for the ingress controller
    ```bash
    $ gcloud compute addresses create ml-static-ip --project=aaet-geoscience-<dev/prod> --region=us-central1
    ```
1) Create the MapLarge TLS Secret.
    ```bash
    $ kubectl create secret tls ml-tls-secret --key="tls.key" --cert="tls.crt"
    ```
1) Create the Ingress Service
    ```bash
    $ kubectl create -f /workspaces/lithos-infrastructure/MapLargeCluster/maplarge-ingress.yaml

    ```
1) Deploy the MapLarge software
#### Updating
To update the k8s cluster with the latest maplarge data, we must first copy the container from maplarge container registry in docker hub into the container registry in GCP. The container should be located in this [GCP Container Registry Path](gcr.io/aaet-geoscience-dev/maplarge/apc)
1) Modify maplarge-master-ss.yaml to have the provided correct MapLarge version information
    ```yaml
    .
    .
    .
            image: gcr.io/aaet-geoscience-dev/maplarge/apc:ubuntu-xenial-4.5.0-3.2.0.20190828200618-dev-MapLarge
    .
    .
    .
    ```
1) Modify copy_maplarge_to_gcp.sh to have the provided correct MapLarge version information
    ```bash
    .
    .
    .
    # You must login using a docker hub account that has been given access to this repository
    TAG_NAME=ubuntu-xenial-4.5.0-3.2.0.20190828200618-dev-MapLarge
    .
    .
    .
    ```
1) Copy the maplarge container image to gcp container repository
    ```bash
    :/workspaces/lithos-infrastructure/MapLargeCluster# ./copy_maplarge_to_gcp.sh 
    Digest: sha256:edf27f677469f2d7ddb387e3048d77c80159d2939188bb0b2358e5e39c7803da
    Status: Image is up to date for maplarge/apc:ubuntu-xenial-4.5.0-3.2.0.20190828200618-dev-MapLarge
    docker.io/maplarge/apc:ubuntu-xenial-4.5.0-3.2.0.20190828200618-dev-MapLarge
    The push refers to repository [gcr.io/aaet-geoscience-dev/maplarge/apc]
    182f762f34b8: Pushed 
    ad2dc940dfd9: Layer already exists 
    92d3f22d44f3: Layer already exists 
    10e46f329a25: Layer already exists 
    24ab7de5faec: Layer already exists 
    1ea5a27b0484: Layer already exists 
    ubuntu-xenial-4.5.0-3.2.0.20190828200618-dev-MapLarge: digest: sha256:edf27f677469f2d7ddb387e3048d77c80159d2939188bb0b2358e5e39c7803da size: 1576

    ```
1) redeploy MapLarge into the cluster (now using the new version)
    ```bash
    /workspaces/lithos-infrastructure/MapLargeCluster# deployMapLarge.sh 
    statefulset.apps "maplarge-master-ss" deleted
    statefulset.apps/maplarge-master-ss created
    ```
1) verify MapLarge is on the right version by going to the Internal IP address for MapLarge, log in, from the right hamburger menu, choose "About"
1) Copy Counties2010 files into Maplarge environment
    * Export Counties Data from Development
    * Import into "Counties2010" table in Production
1) Copy user_aoi_list table into MapLarge environment
    * Export from Developjment
    * import into Production

#### Component Architecture
Simple 

```mermaid
```

### Prerequisites
* See the documentation in the .devcontainer [README.md](./.devcontainer/README.md)
### Getting Started
1) Connect to the appropriate Kubernetes cluster
   ```
   $ gcloud beta container clusters get-credentials maplarge --region us-central1 --project aaet-geoscience-dev
   ```
1)  
### Known Issues
* None yet
