#!/bin/bash


PAPERSPACE_API_KEY=foo
PAPERSPACE_URL_SUFFIX=https://staging-api.paperspace.io
AWS_ACCESS_KEY_ID=foo
AWS_SECRET_ACCESS_KEY=bar
AWS_S3_BUCKET_REGION=us-east-1
S3_BUCKET_PATH=s3://path/to/bucket
DOMAIN=dummy.domain.paperspace.com
CLUSTER_HANDLE=mycluster
PLATFORM=graphcore
DEFAULT_K8S_TYPE=3


cluster_create_response=$(curl -XPOST -H "X-Api-Key: ${PAPERSPACE_API_KEY}" \
"${PAPERSPACE_URL_SUFFIX}/clusters/createCluster?accessKey=${AWS_ACCESS_KEY_ID}\
&bucketPath=${S3_BUCKET_PATH}&secretKey=${AWS_SECRET_ACCESS_KEY}&fqdn=${DOMAIN}\
&name=${CLUSTER_HANDLE}&cloud=${PLATFORM}&region=${AWS_S3_BUCKET_REGION}&type=${DEFAULT_K8S_TYPE}")

# ToDo, use these values to populate the terraform configuration
echo "${cluster_create_response}"