global:
  amqpExchange: ${cluster_handle}
  artifactsPath: ${artifacts_path}
  cluster:
    handle: ${cluster_handle}
    name: ${name}

  natsAuthToken: "${nats_token}"

  logs:
    host: ${logs_host}
  ingressHost: ${domain}
  clusterSecretChecksum: ${cluster_secret_checksum}
  serviceNodeSelector:
    paperspace.com/pool-name: ${service_pool_name}
  serviceResources:
    requests:
      cpu: ${resources["default"]["requests"]["cpu"]}
      memory: ${resources["default"]["requests"]["memory"]}
    limits:
      cpu: ${resources["default"]["limits"]["cpu"]}
      memory: ${resources["default"]["limits"]["memory"]}

  api: ${paperspace_base_url}
  apiNext: ${paperspace_api_next_url}
  dispatcherServerApiAddress: ${dispatcher_host}:443
  clusterAPIHost: ${cluster_api_host}:443

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

      %{ if shared_storage_type == "csi-driver-nfs" }
      mountOptions:
        - nfsvers=3
        - nolock
        - soft
        - lookupcache=none
      # we hardcode this to point to our internal nfs share
      server: nfs-service.default.svc.cluster.local
      share: /opt/gradient-team-data
      %{ endif }

    %{ if shared_storage_type == "csi-driver-nfs" }
    gradient-processing-images:
      class: gradient-processing-images
      type: ${shared_storage_type}
      mountOptions:
        %{ for mountOption in split(",", lookup(shared_storage_config, "mount_options")) }
        - ${ mountOption }
        %{ endfor }
      server: ${shared_storage_config["server"]}
      share: ${shared_storage_config["share"]}
    %{ endif }

csi-driver-nfs:
  enabled: ${shared_storage_type == "csi-driver-nfs" ? true : false }

  controller:
    hostNetwork: false

  node:
    hostNetwork: false

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
    replicaCount: ${ceph_provisioner_replicas}
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}

    %{ if try(resources["cephfs-csi-provisioner"], null) != null }
    provisioner:
      resources:
        requests:
          cpu: ${resources["cephfs-csi-provisioner"]["requests"]["cpu"]}
          memory: ${resources["cephfs-csi-provisioner"]["requests"]["memory"]}
        limits:
          cpu: ${resources["cephfs-csi-provisioner"]["limits"]["cpu"]}
          memory: ${resources["cephfs-csi-provisioner"]["limits"]["memory"]}
    %{ endif }
    %{ if try(resources["cephfs-csi-resizer"], null) != null }
    resizer:
      resources:
        requests:
          cpu: ${resources["cephfs-csi-resizer"]["requests"]["cpu"]}
          memory: ${resources["cephfs-csi-resizer"]["requests"]["memory"]}
        limits:
          cpu: ${resources["cephfs-csi-resizer"]["limits"]["cpu"]}
          memory: ${resources["cephfs-csi-resizer"]["limits"]["memory"]}
    %{ endif }

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
    replicaCount: 2
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}
    %{ if try(resources["rbd-csi-provisioner"], null) != null }
    provisioner:
      resources:
        requests:
          cpu: ${resources["rbd-csi-provisioner"]["requests"]["cpu"]}
          memory: ${resources["rbd-csi-provisioner"]["requests"]["memory"]}
        limits:
          cpu: ${resources["rbd-csi-provisioner"]["limits"]["cpu"]}
          memory: ${resources["rbd-csi-provisioner"]["limits"]["memory"]}
    %{ endif }
    %{ if try(resources["rbd-csi-resizer"], null) != null }
    resizer:
      resources:
        requests:
          cpu: ${resources["rbd-csi-resizer"]["requests"]["cpu"]}
          memory: ${resources["rbd-csi-resizer"]["requests"]["memory"]}
        limits:
          cpu: ${resources["rbd-csi-resizer"]["limits"]["cpu"]}
          memory: ${resources["rbd-csi-resizer"]["limits"]["memory"]}
    %{ endif }
%{ endif }
cluster-autoscaler:
  enabled: ${cluster_autoscaler_enabled}
  %{ if cluster_autoscaler_cloudprovider == "paperspace" }
  image:
    pullPolicy: Always
    repository: paperspace/cluster-autoscaler
    tag: 1.20-1cc038f0793e8dcefb1ae8364b1dfaa044a1d124-amd64

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
  %{ if try(resources["cluster-autoscaler"], null) != null }
  resources:
    requests:
      cpu: ${resources["cluster-autoscaler"]["requests"]["cpu"]}
      memory: ${resources["cluster-autoscaler"]["requests"]["memory"]}
    limits:
      cpu: ${resources["cluster-autoscaler"]["limits"]["cpu"]}
      memory: ${resources["cluster-autoscaler"]["limits"]["memory"]}
  %{ endif }

  awsRegion: ${aws_region}
  autoDiscovery:
    clusterName: ${name}
  cloudProvider: ${cluster_autoscaler_cloudprovider}

  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

dispatcher:
  config: {}
  %{ if try(resources["dispatcher"], null) != null }
  resources:
    requests:
      cpu: ${resources["dispatcher"]["requests"]["cpu"]}
      memory: ${resources["dispatcher"]["requests"]["memory"]}
    limits:
      cpu: ${resources["dispatcher"]["limits"]["cpu"]}
      memory: ${resources["dispatcher"]["limits"]["memory"]}
  %{ endif }

dispatcherNotifier:
  enabled: true

  replicaCount: 4

  config:
    logLevel: "info"
    useSSL: true

  %{ if try(resources["dispatcher-notifier"], null) != null }
  resources:
    requests:
      cpu: ${resources["dispatcher-notifier"]["requests"]["cpu"]}
      memory: ${resources["dispatcher-notifier"]["requests"]["memory"]}
    limits:
      cpu: ${resources["dispatcher-notifier"]["limits"]["cpu"]}
      memory: ${resources["dispatcher-notifier"]["limits"]["memory"]}
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
    workspaceUploadUseSSL: true
    usePodAntiAffinity: ${use_pod_anti_affinity}
    %{ if is_public_cluster }
    notebookPendingTimeout: 900
    %{ endif }
    %{ if is_graphcore }
    notebookPendingTimeout: 45
    %{ endif }

    notebookVolumeType: ${notebook_volume_type}

    %{ if is_graphcore }
    ipuControllerServer: ${ipu_controller_server}
    ipuModelsCachePVCName: ${ipu_model_cache_pvc_name}
    ipuofVipuApiHost: ${ipuof_vipu_api_host}
    ipuofVipuApiPort: ${ipuof_vipu_api_port}
    graphcoreCluster: true
    %{ endif }
    adminTeamHandle: ${admin_team_handle}

    %{ if try(resources["gradient-operator-controller"], null) != null }
    controller:
      resources:
        requests:
          cpu: ${resources["gradient-operator-controller"]["requests"]["cpu"]}
          memory: ${resources["gradient-operator-controller"]["requests"]["memory"]}
        limits:
          cpu: ${resources["gradient-operator-controller"]["limits"]["cpu"]}
          memory: ${resources["gradient-operator-controller"]["limits"]["memory"]}
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

    %{ if try(resources["gradient-operator-state-watcher"], null) != null }
    stateWatcher:
      resources:
        requests:
          cpu: ${resources["gradient-operator-state-watcher"]["requests"]["cpu"]}
          memory: ${resources["gradient-operator-state-watcher"]["requests"]["memory"]}
        limits:
          cpu: ${resources["gradient-operator-state-watcher"]["limits"]["cpu"]}
          memory: ${resources["gradient-operator-state-watcher"]["limits"]["memory"]}
    %{ endif }

    abuseWatcher:
      enabled: false
      antiCryptoMinerRegex: ${anti_crypto_miner_regex}

      %{ if try(resources["gradient-operator-abuse-watcher"], null) != null }
      resources:
        requests:
          cpu: ${resources["gradient-operator-abuse-watcher"]["requests"]["cpu"]}
          memory: ${resources["gradient-operator-abuse-watcher"]["requests"]["memory"]}
        limits:
          cpu: ${resources["gradient-operator-abuse-watcher"]["limits"]["cpu"]}
          memory: ${resources["gradient-operator-abuse-watcher"]["limits"]["memory"]}
      %{ endif }

    %{ if label_selector_cpu != "" && label_selector_gpu != "" }
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
    %{ endif }

gradient-metrics:
  ingress:
    hostPath:
      ${domain}: /metrics
  config:
    connectionString: ${gradient_metrics_conn_str}

  %{ if try(resources["gradient-metrics"], null) != null }
  resources:
    requests:
      cpu: ${resources["gradient-metrics"]["requests"]["cpu"]}
      memory: ${resources["gradient-metrics"]["requests"]["memory"]}
    limits:
      cpu: ${resources["gradient-metrics"]["limits"]["cpu"]}
      memory: ${resources["gradient-metrics"]["limits"]["memory"]}
  %{ endif }

gradient-operator-dispatcher:
  config:
    sentryEnvironment: ${name}
    sentryDSN: ${sentry_dsn}

nfs-subdir-external-provisioner:
  enabled: ${nfs_client_provisioner_enabled}
  nfs:
    path: ${nfs_subdir_external_provisioner_path}
    server: ${nfs_subdir_external_provisioner_server}
  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

victoria-metrics-k8s-stack:
  prometheus-node-exporter:
    enabled: true
    service:
      port: ${victoria_metrics_prometheus_node_exporter_host_port}
      targetPort: ${victoria_metrics_prometheus_node_exporter_host_port}

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
      %{ if try(resources["vmsingle"], null) != null }
      resources:
        limits:
          cpu: ${resources["vmsingle"]["limits"]["cpu"]}
          memory: ${resources["vmsingle"]["limits"]["memory"]}
        requests:
          cpu: ${resources["vmsingle"]["requests"]["cpu"]}
          memory: ${resources["vmsingle"]["requests"]["memory"]}
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
        nodeSelector:
          paperspace.com/pool-name: ${service_pool_name}
        %{ if try(resources["vminsert"], null) != null }
        resources:
          limits:
            cpu: ${resources["vminsert"]["limits"]["cpu"]}
            memory: ${resources["vminsert"]["limits"]["memory"]}
          requests:
            cpu: ${resources["vminsert"]["requests"]["cpu"]}
            memory: ${resources["vminsert"]["requests"]["memory"]}
        %{ endif }
        %{ if is_public_cluster }
        affinity:
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - podAffinityTerm:
                topologyKey: kubernetes.io/hostname
              weight: 100
        %{ endif }
      vmselect:
        %{ if try(resources["vmselect"], null) != null }
        resources:
          limits:
            cpu: ${resources["vmselect"]["limits"]["cpu"]}
            memory: ${resources["vmselect"]["limits"]["memory"]}
          requests:
            cpu: ${resources["vmselect"]["requests"]["cpu"]}
            memory: ${resources["vmselect"]["requests"]["memory"]}
        %{ endif }
        extraArgs:
          search.maxConcurrentRequests: "200"
          search.maxFederateSeries: "6000000"
          search.maxPointsPerTimeseries: "6000000"
          search.maxPointsSubqueryPerTimeseries: "6000000"
          search.maxQueryDuration: 60s
          search.maxSeries: "6000000"
          search.maxUniqueTimeseries: "6000000"
        replicaCount: ${vm_select_replica_count}
        nodeSelector:
          paperspace.com/pool-name: ${prometheus_pool_name}
        %{ if is_public_cluster }
        affinity:
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - podAffinityTerm:
                topologyKey: kubernetes.io/hostname
              weight: 100
        %{ endif }
        storage:
          volumeClaimTemplate:
            spec:
              storageClassName: ${metrics_storage_class}
              resources:
                requests:
                  storage: 20Gi
      vmstorage:
        extraArgs:
          search.maxUniqueTimeseries: "6000000"
          memory.allowedPercent: "75.0"
        replicaCount: ${vm_storage_replica_count}
        storageDataPath: "/vm-data"
        %{ if is_public_cluster }
        affinity:
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - podAffinityTerm:
                topologyKey: kubernetes.io/hostname
              weight: 100
        %{ endif }
        nodeSelector:
          paperspace.com/pool-name: ${prometheus_pool_name}
        storage:
          volumeClaimTemplate:
            spec:
              storageClassName: "${metrics_storage_class}"
            %{ if is_public_cluster }
              resources:
                requests:
                  storage: 500Gi
            %{ endif }
        resources:
        %{ if try(resources["vmstorage"], null) != null }
          requests:
            cpu: ${resources["vmstorage"]["requests"]["cpu"]}
            memory: ${resources["vmstorage"]["requests"]["memory"]}
          limits:
            cpu: ${resources["vmstorage"]["limits"]["cpu"]}
            memory: ${resources["vmstorage"]["limits"]["memory"]}
        %{ endif }
    ingress:
      select:
        hosts:
          - ${domain}

  kube-state-metrics:
    %{ if try(resources["kube-state-metrics"], null) != null }
    resources:
      requests:
        cpu: ${resources["kube-state-metrics"]["requests"]["cpu"]}
        memory: ${resources["kube-state-metrics"]["requests"]["memory"]}
      limits:
        cpu: ${resources["kube-state-metrics"]["limits"]["cpu"]}
        memory: ${resources["kube-state-metrics"]["limits"]["memory"]}
    %{ endif }
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}

  victoria-metrics-operator:
    %{ if is_public_cluster }
    resources:
      requests:
        cpu: ${resources["victoria-metrics-operator"]["requests"]["cpu"]}
        memory: ${resources["victoria-metrics-operator"]["requests"]["memory"]}
      limits:
        cpu: ${resources["victoria-metrics-operator"]["limits"]["cpu"]}
        memory: ${resources["victoria-metrics-operator"]["limits"]["memory"]}
    %{ endif }
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}


  vmagent:
    enabled: true
    spec:
      externalLabels:
        cluster: ${cluster_handle}
      nodeSelector:
        paperspace.com/pool-name: ${service_pool_name}
      %{ if try(resources["vmagent"], null) != null }
      resources:
        requests:
          cpu: ${resources["vmagent"]["requests"]["cpu"]}
          memory: ${resources["vmagent"]["requests"]["memory"]}
        limits:
          cpu: ${resources["vmagent"]["limits"]["cpu"]}
          memory: ${resources["vmagent"]["limits"]["memory"]}
      %{ endif }

    additionalRemoteWrites:
      - url: http://gradient-nats-bridge:8085/prometheus

  kubelet:
    enabled: true
    cadvisor: true
    spec:
      interval: 20s
      scrapeTimeout: 10s

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
      %{ if is_public_cluster }
      accessMode: ReadWriteMany
      %{ endif }
  %{ endif }

  %{ if try(resources["traefik"], null) != null }
  resources:
    requests:
      cpu: ${resources["traefik"]["requests"]["cpu"]}
      memory: ${resources["traefik"]["requests"]["memory"]}
    limits:
      cpu: ${resources["traefik"]["limits"]["cpu"]}
      memory: ${resources["traefik"]["limits"]["memory"]}
  %{ endif }

argo:
  controller:
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}

argo-rollouts:
  controller:
    nodeSelector:
      paperspace.com/pool-name: ${service_pool_name}
%{ if try(resources["argo-rollouts"], null) != null }
    resources:
      requests:
        cpu: ${resources["argo-rollouts"]["requests"]["cpu"]}
        memory: ${resources["argo-rollouts"]["requests"]["memory"]}
      limits:
        cpu: ${resources["argo-rollouts"]["limits"]["cpu"]}
        memory: ${resources["argo-rollouts"]["limits"]["memory"]}
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
    useSSL: true
    sharedStorageClaim: gradient-processing-shared
    prometheusUrl: ${gradient_metrics_conn_str}
    gradientTeamsPersistentVolumeClaimName: ${shared_storage_name}
    %{ if local_storage_type == "ceph-csi-fs" || shared_storage_type == "ceph-csi-fs" }
    volumeType: cephfs
    %{ endif }

    %{ if shared_storage_type == "csi-driver-nfs" }
    # example: /paperspace1 or /exports
    exportPath: ${shared_storage_config["share"]}
    volumeType: disk-image
    imagesVolumeClaimName: gradient-processing-images
    %{ endif }

  %{ if try(resources["volume-controller"], null) != null }
  resources:
    requests:
      cpu: ${resources["volume-controller"]["requests"]["cpu"]}
      memory: ${resources["volume-controller"]["requests"]["memory"]}
    limits:
      cpu: ${resources["volume-controller"]["limits"]["cpu"]}
      memory: ${resources["volume-controller"]["limits"]["memory"]}
  %{ endif }

  %{ if shared_storage_type == "csi-driver-nfs" }
  # if we are using nfs, we want to allow all connections to drops in VC..
  # before rolling out a new pod
  strategy:
    type: Recreate
  %{ endif }

recycleBin:
  enabled: true
  %{ if try(resources["recycle-bin"], null) != null }
  resources:
    requests:
      cpu: ${resources["recycle-bin"]["requests"]["cpu"]}
      memory: ${resources["recycle-bin"]["requests"]["memory"]}
    limits:
      cpu: ${resources["recycle-bin"]["limits"]["cpu"]}
      memory: ${resources["recycle-bin"]["limits"]["memory"]}
  %{ endif }

volumeFs:
  %{ if is_public_cluster }
  replicaCount: 4
  %{ else }
  replicaCount: 1
  %{ endif }

prometheus-adapter:
  enabled: true

  prometheus:
    url: ${gradient_metrics_adapter_endpoint}
    port: ${gradient_metrics_port}
    path: ${gradient_metrics_path}

nodeHealthChecks:
  enabled: ${ node_health_check_enabled }

nats:
  enabled: true

  nodeSelector:
    paperspace.com/pool-name: ${service_pool_name}

  auth:
    enabled: true
    token: "${nats_token}"

  cluster:
    enabled: true
    replicas: 3

  %{ if try(resources["nats"], null) != null }
  resources:
    requests:
      cpu: ${resources["nats"]["requests"]["cpu"]}
      memory: ${resources["nats"]["requests"]["memory"]}
    limits:
      cpu: ${resources["nats"]["limits"]["cpu"]}
      memory: ${resources["nats"]["limits"]["memory"]}
  %{ endif }

  nats:
    jetstream:
      enabled: true

      memStorage:
        enabled: false
        size: 10Gi

      fileStorage:
        enabled: true
        size: 1Ti
        storageClassName: ${nats_storage_class}

telemetry:
  enabled: true

  replicaCount: 4

  config:
    logLevel: "info"
    logsAPI: ${logs_host}
    useSSL: true

  %{ if try(resources["telemetry"], null) != null }
  resources:
    requests:
      cpu: ${resources["telemetry"]["requests"]["cpu"]}
      memory: ${resources["telemetry"]["requests"]["memory"]}
    limits:
      cpu: ${resources["telemetry"]["limits"]["cpu"]}
      memory: ${resources["telemetry"]["limits"]["memory"]}
  %{ endif }

natsBridge:
  enabled: true

  %{ if try(resources["nats-bridge"], null) != null }
  resources:
    requests:
      cpu: ${resources["nats-bridge"]["requests"]["cpu"]}
      memory: ${resources["nats-bridge"]["requests"]["memory"]}
    limits:
      cpu: ${resources["nats-bridge"]["limits"]["cpu"]}
      memory: ${resources["nats-bridge"]["limits"]["memory"]}
  %{ endif }

  config:
    port: 8085

  replicaCount: 3
