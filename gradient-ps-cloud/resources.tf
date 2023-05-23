locals {
  public_cluster_resource_defaults = {
    "default" = {
      "limits" = {
        "cpu"    = "250m"
        "memory" = "512Mi"
      }
    }
    "dispatcher" = {
      "limits" = {
        "cpu"    = "1000m"
        "memory" = "2Gi"
      },
    },
    "gradient-operator-controller" = {
      "limits" = {
        "cpu"    = "1000m"
        "memory" = "3Gi"
      },
    },
    "gradient-operator-state-watcher" = {
      "limits" = {
        "cpu"    = "250m"
        "memory" = "768Mi"
      }
    },
    "gradient-operator-abuse-watcher" = {
      "limits" = {
        "cpu"    = "250m"
        "memory" = "1Gi"
      }
    },
    "gradient-metrics" = {
      "limits" = {
        "cpu"    = "1000m"
        "memory" = "512Mi"
      }
    },
    "kube-state-metrics" = {
      "limits" = {
        "cpu"    = "250m"
        "memory" = "2Gi"
      }
    },
    "victoria-metrics-operator" = {
      "limits" = {
        "cpu"    = "500m"
        "memory" = "1Gi"
      }
    },
    "argo-rollouts" = {
      "limits" = {
        "cpu"    = "250m"
        "memory" = "512Mi"
      }
    },
    "recylcle-bin" = {
      "limits" = {
        "cpu"    = "250m"
        "memory" = "1Gi"
      }
    },
  }

  // start to remove the "is_public_cluster" defaults and instead set profiles by the machine types that host the services
  // you will need to duplicate profiles by machine type, c8 won't inherit from c7, etc
  service_resource_defaults_by_machine_type = {
    "C8" = {
      "argo-rollouts" = {
        "limits" = {
          "cpu"    = "1"
          "memory" = "1Gi"
        }
      },
      "cluster-autoscaler" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "4Gi"
        }
      },
      "rbd-csi-provisioner" = {
        "limits" = {
          "cpu"    = "500m"
          "memory" = "4Gi"
        },
      },
      "rbd-csi-resizer" = {
        "limits" = {
          "cpu"    = "1"
          "memory" = "4Gi"
        },
      },
      "cephfs-csi-provisioner" = {
        "limits" = {
          "cpu"    = "1"
          "memory" = "4Gi"
        },
      },
      "cephfs-csi-resizer" = {
        "limits" = {
          "cpu"    = "1"
          "memory" = "4Gi"
        },
      },
      "volume-controller" = {
        "limits" = {
          "cpu"    = "3000m"
          "memory" = "16Gi"
        }
      },
      "gradient-metrics" = {
        "limits" = {
          "cpu"    = "2"
          "memory" = "1Gi"
        }
      },
      "kube-state-metrics" = {
        "limits" = {
          "cpu"    = "2"
          "memory" = "4Gi"
        }
      },
      "vmselect" = {
        "limits" = {
          "cpu"    = "6"
          "memory" = "15Gi"
        }
      },
      "vmstorage" = {
        "storage" : "500Gi"
        "limits" = {
          "cpu"    = "12"
          "memory" = "50Gi"
        }
      },
      "vmagent" = {
        "limits" = {
          "cpu"    = "4"
          "memory" = "12Gi"
        }
      },
      "dispatcher-notifier" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "256Mi"
        }
      },
      "telemetry" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "2Gi"
        }
      },
      "nats-bridge" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "1Gi"
        }
      },
      "nats" = {
        "limits" = {
          "cpu"    = "12"
          "memory" = "50Gi"
        }
      }
    },

    "C7" = {
      "cluster-autoscaler" = {
        "limits" = {
          "cpu"    = "500m"
          "memory" = "2Gi"
        }
      },
      "rbd-csi-provisioner" = {
        "limits" = {
          "cpu"    = "250m"
          "memory" = "1Gi"
        },
      },
      "rbd-csi-resizer" = {
        "limits" = {
          "cpu"    = "250m"
          "memory" = "1Gi"
        },
      },
      "cephfs-csi-provisioner" = {
        "limits" = {
          "cpu"    = "500m"
          "memory" = "1Gi"
        },
      },
      "cephfs-csi-resizer" = {
        "limits" = {
          "cpu"    = "500m"
          "memory" = "1Gi"
        },
      },
      "volume-controller" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "4Gi"
        }
      },
      "vmselect" = {
        "limits" = {
          "cpu"    = "4"
          "memory" = "10Gi"
        }
      },
      "vmstorage" = {
        "storage" : "500Gi"
        "limits" = {
          "cpu"    = "3"
          "memory" = "12Gi"
        }
      },
      "vmagent" = {
        "limits" = {
          "cpu"    = "2"
          "memory" = "6Gi"
        }
      },
      "telemetry" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "2Gi"
        }
      },
      "dispatcher-notifier" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "256Mi"
        }
      },
      "nats-bridge" = {
        "limits" = {
          "cpu"    = "1000m"
          "memory" = "1Gi"
        }
      },
      "nats" = {
        "limits" = {
          "cpu"    = "2"
          "memory" = "8Gi"
        }
      }
    },
  }

  // this should only contain traefik, but needs to be a map to merge with the other maps
  lb_resource_defaults_by_machine_type = {

    "C7" = {
      "traefik" = {
        "limits" = {
          "cpu"    = "10"
          "memory" = "28Gi"
        }
      },
    }
  }


  resources = merge(
    local.service_resource_defaults,
    local.is_public_cluster ? local.public_cluster_resource_defaults : {},
    lookup(local.service_resource_defaults_by_machine_type, var.machine_type_service, {}),
    lookup(local.lb_resource_defaults_by_machine_type, var.machine_type_lb, {}),
  )
}
