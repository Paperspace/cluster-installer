locals {
  guest_health_report_path = "/var/log/ps-guest-agent"
  guest_health_args        = [format("%s/guest-health.json", local.guest_health_report_path)]
  guest_health_path        = "/custom-plugin/bin/linux-guest-health.sh"
}

module "node_problem_detector" {
  source = "../modules/node-problem-detector"

  draino_flags = {
    skip_drain = true
    node_label_expr = "metadata.labels['node-role.kubernetes.io/worker'] == 'true' && metadata.labels['paperspace.com/pool-name'] != 'lb' && metadata.labels['paperspace.com/pool-name'] != 'services-small'"
  }

  draino_node_selector = {
    "paperspace.com/pool-name" = var.service_pool_name
  }

  custom_plugin_scripts = {
    "linux-guest-health.sh" = file("${path.module}/files/linux-guest-health.sh")
  }

  node_problem_detector_image = {
    repository = "paperspace/node-problem-detector"
    tag        = "v0.8.12-jq"
  }

  node_problem_detector_extra_volumes = [
    {
      name = "guest-health"
      hostPath = {
        path = local.guest_health_report_path
        type = "DirectoryOrCreate"
      }
    },
  ]
  node_problem_detector_extra_volume_mounts = [
    {
      name      = "guest-health"
      mountPath = local.guest_health_report_path
      readOnly  = true
    },
  ]

  custom_plugin_configs = {
    "linux-guest-health.json" = {
      source = "linux-guest-health"
      conditions = [
        {
          type    = "CloudInit"
          reason  = "CloudInitDone"
          message = "Cloud-init has completed"
        },
        {
          type    = "Hostname"
          reason  = "HostnameEstablished"
          message = "Hostname has been established"
        },
        {
          type    = "CPU"
          reason  = "CPUReady"
          message = "The expected number of CPUs are available"
        },
        {
          type    = "PCI"
          reason  = "PCIDevicesReady"
          message = "All expected PCI devices (GPUs) are attached"
        },
        {
          type    = "NvidiaGPUs"
          reason  = "NvidiaGPUsReady"
          message = "All gpu devices are ready to use"
        },
        {
          type    = "Memory"
          reason  = "MemoryReady"
          message = "The expected amount of memory is available"
        },
        {
          type    = "Disks"
          reason  = "DisksReady"
          message = "All VM attached disks are ready to use"
        },
      ]
      rules = [
        {
          type      = "permanent"
          condition = "CloudInit"
          reason    = "CloudInitNotDone"
          path      = local.guest_health_path
          args      = concat(local.guest_health_args, ["cloud-init"])
        },
        {
          type      = "permanent"
          condition = "Hostname"
          reason    = "HostnameNotEstablished"
          path      = local.guest_health_path
          args      = concat(local.guest_health_args, ["hostname"])
        },
        {
          type      = "permanent"
          condition = "CPU"
          reason    = "CPUsNotReady"
          path      = local.guest_health_path
          args      = concat(local.guest_health_args, ["cpu"])
        },
        {
          type      = "permanent"
          condition = "PCI"
          reason    = "PCIDevicesNotReady"
          path      = local.guest_health_path
          args      = concat(local.guest_health_args, ["pci"])
        },
        {
          type      = "permanent"
          condition = "NvidiaGPUs"
          reason    = "NvidiaGPUsNotReady"
          path      = local.guest_health_path
          args      = concat(local.guest_health_args, ["gpu"])
        },
        {
          type      = "permanent"
          condition = "Memory"
          reason    = "MemoryNotReady"
          path      = local.guest_health_path
          args      = concat(local.guest_health_args, ["memory"])
        },
        {
          type      = "permanent"
          condition = "Disks"
          reason    = "DiskNotReady"
          path      = local.guest_health_path
          args      = concat(local.guest_health_args, ["disks"])
        },
      ]
    },
  }
}
