global:
  amqpExchange: ${cluster_handle}

  artifactsPath: ${artifacts_path}
  cluster:
    handle: ${cluster_handle}
    name: ${name}
  %{ if elastic_search_enabled }
  elasticSearch:
    host: ${elastic_search_host}
    index: ${elastic_search_index}
    port: ${elastic_search_port}
    user: ${elastic_search_user}
  %{ endif }

  logs:
    host: ${logs_host}
  ingressHost: ${domain}
  clusterSecretChecksum: ${cluster_secret_checksum}
  serviceNodeSelector:
    paperspace.com/pool-name: ${service_pool_name}
  serviceResources:
    %{ if is_public_cluster }
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 250m
      memory: 512Mi
   %{ else }
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 128Mi
   %{ endif }

  api: ${paperspace_base_url}
  apiNext: ${paperspace_api_next_url}

  defaultStorageName: ${default_storage_name}
  sharedStorageName: ${shared_storage_name}
  storage:
    gradient-processing-local:
      class: gradient-processing-local
      path: ${local_storage_path}
      server: ${local_storage_server}
      type: ${local_storage_type}

      %{ if local_storage_type == "ceph-csi-fs" }
      monitors:
        %{ for monitor in split(",", lookup(local_storage_config, "monitors")) }
        - ${ monitor }
        %{ endfor }

      user: ${local_storage_config["user"]}
      password: ${local_storage_config["password"]}
      fsName: ${local_storage_config["fsName"]}
      %{ endif }
    gradient-processing-shared:
      class: gradient-processing-shared
      path: ${shared_storage_path}
      server: ${shared_storage_server}
      type: ${shared_storage_type}

      %{ if shared_storage_type == "ceph-csi-fs" }
      user: ${shared_storage_config["user"]}
      password: ${shared_storage_config["password"]}
      fsName: ${shared_storage_config["fsName"]}
      monitors:
        %{ for monitor in split(",", lookup(shared_storage_config, "monitors")) }
        - ${ monitor }
        %{ endfor }

      %{ endif }

ceph-csi-cephfs:
  enabled: ${local_storage_type == "ceph-csi-fs" || shared_storage_type == "ceph-csi-fs" ? true : false }
  csiConfig:
    %{ if local_storage_type == "ceph-csi-fs" }
    - clusterID: gradient-processing-local
      monitors:
      %{ for monitor in split(",", lookup(local_storage_config, "monitors")) }
        - ${ monitor }
      %{ endfor }
    %{ endif }
    %{ if shared_storage_type == "ceph-csi-fs" }
    - clusterID: gradient-processing-shared
      monitors:
      %{ for monitor in split(",", lookup(shared_storage_config, "monitors")) }
        - ${ monitor }
      %{ endfor }
    %{ endif }
  provisioner:
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}

# https://github.com/kubernetes-csi/external-provisioner/releases
%{ if length(rbd_storage_config) != 0 }
ceph-csi-rbd:
  enabled: true
  storageClass:
    clusterID: ${cluster_handle}
    pool: ${rbd_storage_config["rbdPool"]}
  csiConfig:
    - clusterID: ${cluster_handle}
      monitors:
      %{ for monitor in split(",", lookup(rbd_storage_config, "monitors")) }
        - ${ monitor }
      %{ endfor }
  secret:
    create: true
    userID: ${rbd_storage_config["user"]}
    userKey: ${rbd_storage_config["password"]}
  provisioner:
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}
    %{ if is_public_cluster }
    image:
      repository: k8s.gcr.io/sig-storage/csi-provisioner
      tag: v3.1.0
    resources:
      requests:
        cpu: 500m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 2Gi
    %{ endif }
  resizer:
    %{ if is_public_cluster }
    resources:
      requests:
        cpu: 500m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 2Gi
    %{ endif }
%{ endif }
cluster-autoscaler:
  enabled: ${cluster_autoscaler_enabled}
  %{ if cluster_autoscaler_cloudprovider == "paperspace" }
  image:
    pullPolicy: Always
    repository: paperspace/cluster-autoscaler
    tag: 1.20-e35f4d0e54a4bf9fa1d7d3e75157b32851878632

  autoscalingGroups:
    %{ for autoscaling_group in cluster_autoscaler_autoscaling_groups }
    - name: ${autoscaling_group["name"]}
      minSize: ${autoscaling_group["min"]}
      maxSize: ${autoscaling_group["max"]}
    %{ endfor }
  extraArgs:
    ignore-daemonsets-utilization: true
    skip-nodes-with-system-pods: false
    %{ if cluster_autoscaler_unneeded_time != "" }
    scale-down-delay-after-add: ${cluster_autoscaler_delay_after_add}
    scale-down-unneeded-time: ${cluster_autoscaler_unneeded_time}
    %{ endif }
  extraEnv:
    PAPERSPACE_BASEURL: ${paperspace_base_url}
    PAPERSPACE_CLUSTER_ID: ${cluster_handle}
  extraEnvSecrets:
    PAPERSPACE_APIKEY:
      name: gradient-processing
      key: PS_API_KEY

  %{ endif }
  %{ if is_public_cluster }
  resources:
    requests:
      cpu: 500m
      memory: 3072Mi
    limits:
      cpu: 500m
      memory: 3072Mi
  %{ else }
  resources:
    limits:
      cpu: 100m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 512Mi
  %{ endif }

  awsRegion: ${aws_region}
  autoDiscovery:
    clusterName: ${name}
  cloudProvider: ${cluster_autoscaler_cloudprovider}

  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

dispatcher:
  config:
    apiAddress: ${dispatcher_host}
    %{ if is_public_cluster }
    resources:
      requests:
        cpu: 250m
        memory: 512Mi
      limits:
        cpu: 250m
        memory: 800Mi
    %{ endif }


efs-provisioner:
  enabled: ${efs_provisioner_enabled}
  efsProvisioner:
    awsRegion: ${aws_region}
    efsFileSystemId: "${split(".", shared_storage_server)[0]}"
    path: ${shared_storage_path}
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

fluent-bit:
  env:
    - name: PS_LOGS_HOST
      value: ${logs_host}
    - name: PS_CLUSTER_HANDLE
      value: ${cluster_handle}
    - name: PS_CLUSTER_AUTHORIZATION_TOKEN
      valueFrom:
        secretKeyRef:
          name: gradient-processing
          key: PS_CLUSTER_AUTHORIZATION_TOKEN

gradient-operator:
  config:
    ingressHost: ${domain}
    usePodAntiAffinity: ${use_pod_anti_affinity}

    %{ if is_public_cluster }
    controller:
      resources:
        requests:
          cpu: 1000m
          memory: 3072Mi
        limits:
          cpu: 1000m
          memory: 3072Mi
    %{ endif }

    %{ if pod_assignment_label_name != "" }
    podAssignmentLabelName: ${pod_assignment_label_name}
    %{ endif }
    %{ if legacy_datasets_host_path != "" }
    legacyDatasetsHostPath: ${legacy_datasets_host_path}
    %{ endif }
    %{ if legacy_datasets_pvc_name != "" }
    legacyDatasetsPVCName: ${legacy_datasets_pvc_name}
    %{ endif }
    %{ if legacy_datasets_sub_path != "" }
    legacyDatasetsSubPath: ${legacy_datasets_sub_path}
    %{ endif }

    %{ if is_public_cluster }
    stateWatcher:
      resources:
        requests:
          cpu: 250m
          memory: 768Mi
        limits:
          cpu: 250m
          memory: 768Mi
    %{ endif }

    abuseWatcher:
      enabled: false
      antiCryptoMinerRegex: ${anti_crypto_miner_regex}

      %{ if is_public_cluster }
      resources:
        requests:
          cpu: 250m
          memory: 1Gi
        limits:
          cpu: 250m
          memory: 1Gi
      %{ endif }

    %{ if label_selector_cpu != "" && label_selector_gpu != "" }
    modelDeploymentConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi

    experimentConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi
    notebookConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi
    tensorboardConfig:
      labelName: paperspace.com/pool-name
      cpu:
        small:
          label: ${label_selector_cpu}
        medium:
          label: ${label_selector_cpu}
        large:
          label: ${label_selector_cpu}
      gpu:
        small:
          label: ${label_selector_gpu}
          requests:
            memory: 5Gi
        medium:
          label: ${label_selector_gpu}
          requests:
            memory: 20Gi
        large:
          label: ${label_selector_gpu}
          requests:
            memory: 58Gi
    %{ endif }

gradient-metrics:
  ingress:
    hostPath:
      ${domain}: /metrics
  config:
    connectionString: ${gradient_metrics_conn_str}
    newRelicEnabled: ${metrics_new_relic_enabled}
    newRelicName: ${metrics_new_relic_name}

gradient-operator-dispatcher:
  config:
    sentryEnvironment: ${name}
    sentryDSN: ${sentry_dsn}

nfs-subdir-external-provisioner:
  enabled: ${nfs_client_provisioner_enabled}
  nfs:
    path: ${shared_storage_path}
    server: ${shared_storage_server}
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

victoria-metrics-k8s-stack:
  vmsingle:
    enabled: ${enable_victoria_metrics_vm_single}
    spec:
      storage:
        storageClassName: ${metrics_storage_class}
      %{ if is_public_cluster }
        resources:
          requests:
            storage: 400Gi
      %{ endif }
      nodeSelector:
        paperspace.com/pool-name: ${prometheus_pool_name}
      %{ if prometheus_resources != null }
      resources:
        limits:
          cpu: ${prometheus_resources["cpu"]}
          memory: ${prometheus_resources["memory"]}
        requests:
          cpu: ${prometheus_resources["cpu"]}
          memory: ${prometheus_resources["memory"]}
      %{ endif }
    ingress:
      hosts:
        - ${domain}
        
  vmcluster:
    enabled: ${enable_victoria_metrics_vm_cluster}
    spec:
      retentionPeriod: "2w"
      vminsert:
        extraArgs:
          maxLabelsPerTimeseries: "70"
      vmselect:
        resources:
          limits:
            cpu: "2"
            memory: 4Gi
        extraArgs:
          search.maxConcurrentRequests: "200"
          search.maxQueryDuration: "60s"
        replicaCount: ${vm_select_replica_count}
        nodeSelector:
          paperspace.com/pool-name: ${prometheus_pool_name}
        storage:
          volumeClaimTemplate:
            spec:
              storageClassName: "gradient-processing-local"
              resources:
                requests:
                  storage: 2Gi
      vmstorage:
        extraArgs:
          search.maxUniqueTimeseries: "6000000"
          memory.allowedPercent: "45.0"
        replicaCount: ${vm_storage_replica_count}
        storageDataPath: "/vm-data"
        nodeSelector:
          paperspace.com/pool-name: ${prometheus_pool_name}
        storage:
          volumeClaimTemplate:
            spec:
              storageClassName: "${metrics_storage_class}"
            %{ if is_public_cluster }
              resources:
                requests:
                  storage: 100Gi
            %{ endif }
        resources:
          requests:
            cpu: "0.5"
            memory: 0.5Gi
          limits:
            cpu: "4"
            memory: 10Gi
    ingress:
      select:
        hosts:
          - ${domain}

  kube-state-metrics:
    %{ if is_public_cluster }
    resources:
      requests:
        cpu: 500m
        memory: 2Gi
      limits:
        cpu: 500m
        memory: 2Gi
    %{ endif }
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}

  victoria-metrics-operator:
    %{ if is_public_cluster }
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 500m
        memory: 1Gi
    %{ endif }
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}


  vmagent:
    spec:
      kubelet:
        spec:
          interval: 10s
          scrapeTimeout: 6s
      externalLabels:
        cluster: ${cluster_handle}
      nodeSelector:
        paperspace.com/pool-name: ${service_pool_name}
      %{ if is_public_cluster }
      resources:
        requests:
          cpu: 1000m
          memory: 2Gi
        limits:
          cpu: 1000m
          memory: 2Gi
      %{ endif }

traefik:
  replicas: ${lb_count}
  nodeSelector:
    paperspace.com/pool-name: ${lb_pool_name}

  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          topologyKey: "kubernetes.io/hostname"

  %{ if (label_selector_cpu != "" && label_selector_gpu != "") || cluster_autoscaler_cloudprovider == "paperspace" }
  serviceType: NodePort
  deploymentStrategy:
    type: Recreate
  deployment:
    hostNetwork: true
    hostPort:
      httpEnabled: true
      httpPort: 80
      httpsEnabled: true
      httpsPort: 443
  %{ endif }

  %{ if letsencrypt_enabled }
  acme:
    enabled: true
    email: "admin@${domain}"
    onHostRule: true
    staging: false
    logging: true
    domains:
      enabled: true
      domainsList:
        - main: "*.${domain}"
        - sans:
          - ${domain}
    challengeType: dns-01
    resolvers:
      - 8.8.8.8:53
    persistence:
      storageClass: ${shared_storage_name}
  %{ endif }

  %{ if is_public_cluster }
  resources:
    requests:
      cpu: 2
      memory: 2Gi
    limits:
      cpu: 2
      memory: 2Gi
  %{ endif }

argo:
  controller:
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}

argo-rollouts:
  controller:
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}
%{ if is_public_cluster }
    resources:
      requests:
        cpu: 250m
        memory: 512Mi
      limits:
        cpu: 250m
        memory: 512Mi
%{ else }
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 128Mi
%{ endif }

%{ if image_cache_enabled }
imageCacher:
  enabled: true
  config:
    maxParallelism: 10
    images: ${image_cache_list}
%{ endif }


volumeController:
  enabled: true
  config:
    gradientTeamsPersistentVolumeClaimName: ${shared_storage_name}
    %{ if local_storage_type == "ceph-csi-fs" }
    volumeType: cephfs
    %{ endif }
  %{ if is_public_cluster }
  resources:
    requests:
      cpu: 500m
      memory: 2048Mi
    limits:
      cpu: 500m
      memory: 2048Mi
  %{ endif }

recycleBin:
  enabled: true
  %{ if is_public_cluster }
  resources:
    requests:
      cpu: 250m
      memory: 1Gi
    limits:
      cpu: 500m
      memory: 1Gi
  %{ endif }


%{ if is_public_cluster }
gradient-experiment-watcher:
  enabled: false

gradient-model-deployment-watcher:
  enabled: false

gradient-model-deployment-autoscaler:
  enabled: false
%{ endif }
