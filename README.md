# Cluster Installer

![combined](https://user-images.githubusercontent.com/585865/89805086-1c09a380-db03-11ea-975f-5c8aa65a26fa.png)

Run the [Cluster MLOps Platform](https://cluster.paperspace.com) anywhere. The Cluster Installer is a CLI to setup and manage [Cluster private clusters](https://docs.paperspace.com/cluster/cluster-private-cloud/setup) on AWS, NVIDIA DGX-1, and any VM / Bare metal.

Terraform is used under the hood to setup all the infrastructure. Terraform modules can also be used directly to integrate Cluster into an existing Terraform setup.

### Supported target platforms

- AWS EKS
- NVIDIA DGX
- VM / Bare metal
- GCP (GKE) _(coming soon)_
- Azure (AKS) _(coming soon)_

## Prerequisites

- A Paperspace account with an appropriate billing plan and API key [https://www.paperspace.com]
- An AWS S3 bucket to store Terraform state [https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html]

## Install / Update

### Install

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Paperspace/cluster-installer/master/bin/install)"
```

### Updating

```sh
cluster-installer update
```

## Usage

### `cluster-installer`

<img width="633" alt="clusterInstaller-help" src="https://user-images.githubusercontent.com/585865/89807443-a0115a80-db06-11ea-8226-c68c884b03ae.png">

### Setting up a Cluster private cluster

```sh
cluster-installer clusters up
```

<img width="633" alt="ClusterInstallerCLI-up" src="https://user-images.githubusercontent.com/585865/88327177-cb1d4100-ccf4-11ea-8ea8-2c4966c5dd88.png">

### Updating existing clusters

```sh
cluster-installer clusters up CLUSTER_HANDLE
```

### Profiles

The CLI supports multiple profiles, which can be used for different teams. You can use a profile by:

```sh
export PAPERSPACE_PROFILE=favorite-team
cluster-installer setup
```

## Terraform

To keep track of your cluster' state, the CLI stores your state file in an S3 bucket.
Terraform modules can be used directly to create clusters.

List of available Terraform modules:

- cluster-aws
- cluster-metal
- cluster-ps-cloud

## Documentation

Full docs: https://docs.paperspace.com/cluster/cluster-private-cloud/about
