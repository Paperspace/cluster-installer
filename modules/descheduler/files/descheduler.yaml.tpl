kind: Deployment
deschedulerPolicy:
  strategies:
    "RemoveFailedPods":
      enabled: true
      params:
        failedPods:
          reasons:
          - "Evicted"
          includingInitContainers: true
        labelSelector:
          matchExpressions:
            - { key: "paperspace.com/deployment-id", operator: Exists }
    "RemoveDuplicates":
       enabled: true
       params:
         removeDuplicates:
           excludeOwnerKinds:
           - "ReplicaSet"
