FROM hashicorp/terraform:1.0.9

RUN apk add ansible curl bash

RUN mkdir /home/paperspace

ADD . /home/paperspace/gradient-installer

WORKDIR /home/paperspace/gradient-cluster
ENTRYPOINT
CMD terraform init && terraform plan
