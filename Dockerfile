FROM hashicorp/terraform:1.5.6

RUN apk add ansible curl bash

RUN mkdir /home/paperspace

ADD . /home/paperspace/cluster-installer

WORKDIR /home/paperspace/gradient-cluster
ENTRYPOINT
CMD terraform init && terraform plan
