FROM hashicorp/terraform:1.6

RUN apk add --upgrade ansible curl bash libcurl

RUN mkdir /home/paperspace

ADD . /home/paperspace/cluster-installer

WORKDIR /home/paperspace/gradient-cluster
ENTRYPOINT
CMD terraform init && terraform plan
