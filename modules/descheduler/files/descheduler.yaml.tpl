kind: Deployment
deschedulerPolicy:
  strategies:
    "RemoveEvictedDeploymentPods":
      enabled: true
      params:
        failedPods:
          reasons:
          - "Evicted"
          includingInitContainers: true
        labelSelector:
          matchLabels:
            paperspace.com/entity-name: deploymentSpec
