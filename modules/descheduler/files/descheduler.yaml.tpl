kind: Deployment
nodeSelector:
  paperspace.com/pool-name: ${pool_name}
deschedulerPolicy:
  strategies:
    RemoveFailedPods:
      enabled: true
      params:
        failedPods:
          reasons:
            - Evicted
          includingInitContainers: true
    RemoveDuplicates:
      enabled: true
      params:
        removeDuplicates:
          excludeOwnerKinds:
            - ReplicaSet
    RemovePodsHavingTooManyRestarts:
      enabled: true
      params:
        podsHavingTooManyRestarts:
          podRestartThreshold: 3
          includingInitContainers: true
    PodLifeTime:
      enabled: true
      params:
        podLifeTime:
          maxPodLifeTimeSeconds: 600
          states:
            - Pending
            - Terminating
    RemovePodsViolatingInterPodAntiAffinity:
      enabled: false
    RemovePodsViolatingNodeAffinity:
      enabled: false
    RemovePodsViolatingNodeTaints:
      enabled: false
    RemovePodsViolatingTopologySpreadConstraint:
      enabled: false
    LowNodeUtilization:
      enabled: false
    HighNodeUtilization:
      enabled: false
