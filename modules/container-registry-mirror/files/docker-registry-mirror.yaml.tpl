# TODO(bbatha): tls commented out, certmanager does not seem to play well with multiple replicas
fullnameOverride: ${fullname}

replicaCount: ${replica_count}

storage: s3

%{ if docker_registry_s3_storage != null }
s3:
    region: "${docker_registry_s3_storage.region}"
    regionEndpoint: "${docker_registry_s3_storage.region_endpoint}"
    bucket: "${docker_registry_s3_storage.bucket}"
%{ endif }

proxy:
    username: "${docker_username}"
    password: "${docker_password}"

haSharedSecret: "${ha_shared_secret}"

%{ if docker_registry_s3_storage != null }
secrets:
    s3:
        accessKey: "${docker_registry_s3_storage.access_key}"
        secretKey: "${docker_registry_s3_storage.secret_key}"
%{ endif }

persistence:
    deleteEnabled: true
%{ if docker_registry_pvc_storage != null }
    enabled: true
    size: ${docker_registry_pvc_storage.size}
    storageClass: ${docker_registry_pvc_storage.storage_class}
    existingClaim: ${docker_registry_pvc_storage.existing_claim}
%{ endif }


ingress:
  enabled: true
  annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "false"

  hosts:
  - ${hostname}
