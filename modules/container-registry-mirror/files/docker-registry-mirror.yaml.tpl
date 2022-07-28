# TODO(bbatha): tls commented out, certmanager does not seem to play well with multiple replicas
fullnameOverride: ${fullname}

replicaCount: ${replica_count}

storage: ${storage}

%{ if s3 != null }
s3:
    region: "${s3.region}"
    regionEndpoint: "${s3.region_endpoint}"
    bucket: "${s3.bucket}"
%{ endif }

proxy:
    username: "${docker_username}"
    password: "${docker_password}"

haSharedSecret: "${ha_shared_secret}"

%{ if s3 != null }
secrets:
    s3:
        accessKey: "${s3.access_key}"
        secretKey: "${s3.secret_key}"
%{ endif }

persistence:
    deleteEnabled: true
%{ if pvc != null }
    enabled: true
    size: ${pvc.size}
    storageClass: ${pvc.storage_class}
    existingClaim: ${pvc.existing_claim}
%{ endif }


ingress:
  enabled: true
  annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "false"

  hosts:
  - ${hostname}
