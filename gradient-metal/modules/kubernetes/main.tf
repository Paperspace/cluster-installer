locals {
    cluster_file = "cluster.yml"
    rke_nodes = concat([for master_ip in var.master_ips : {
        ip = master_ip
        labels = {
            "node-role.kubernetes.io/master" = ""
            "node-role.kubernetes.io/controller" = true
            "paperspace.com/pool-name" = var.service_pool_name
            "paperspace.com/pool-type" = var.master_pool_type
        }
        roles = [
            "controlplane",
            "etcd",
            "worker",
        ]
        pool-type = var.master_pool_type
    }], [ for worker in var.workers : {
        ip = worker["ip"]
        labels = {
            "node-role.kubernetes.io/node": ""
            "node-role.kubernetes.io/worker": ""
            "paperspace.com/pool-name" = worker["pool-name"]
            "paperspace.com/pool-type" = worker["pool-type"]
        }
        roles = [
            "worker",
        ]
        pool-type = worker["pool-type"]
    }])
    worker_ips = [for worker in var.workers : worker.ip]
}

resource "null_resource" "rke_nodes_wait" {
    count = length(local.rke_nodes)

    provisioner "file" {
        content = file("${path.module}/files/setup-docker.sh")
        destination = "/tmp/setup-docker.sh"
        connection {
            type     = "ssh"
            user     = var.ssh_user
            host     = local.rke_nodes[count.index].ip
            private_key = file(pathexpand(var.ssh_key_path))
        }
    }

    provisioner "file" {
        content = file("${path.module}/files/setup-nvidia.sh")
        destination = "/tmp/setup-nvidia.sh"
        connection {
            type     = "ssh"
            user     = var.ssh_user
            host     = local.rke_nodes[count.index].ip
            private_key = file(pathexpand(var.ssh_key_path))
        }
    }

    provisioner "local-exec" {
        command = "mkdir -p ~/.ssh && ssh-keyscan -H ${local.rke_nodes[count.index].ip} >> ~/.ssh/known_hosts"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo DOCKER_USER=${var.ssh_user} SETUP_DOCKER=${var.setup_docker} sh /tmp/setup-docker.sh",
            "sudo POOL_TYPE=${local.rke_nodes[count.index]["pool-type"]} SETUP_NVIDIA=${var.setup_nvidia} sh /tmp/setup-nvidia.sh"
        ]

        connection {
            type     = "ssh"
            user     = var.ssh_user
            host     = local.rke_nodes[count.index].ip
            private_key = file(pathexpand(var.ssh_key_path))
        }
    }

    provisioner "local-exec" {
        command = "echo 'Waiting for ${local.rke_nodes[count.index].ip}'"
        connection {
            type     = "ssh"
            user     = var.ssh_user
            host     = local.rke_nodes[count.index].ip
            private_key = file(pathexpand(var.ssh_key_path))
        }
    }
}

resource "rke_cluster" "main" {
    depends_on = [null_resource.rke_nodes_wait]
    cluster_name = var.name

    dynamic "nodes" {
        for_each = local.rke_nodes

        content {
            address = nodes.value["ip"]
            docker_socket = var.docker_socket
            labels = nodes.value["labels"]
            role    = nodes.value["roles"]
            ssh_key = file(var.ssh_key_path)
            user    = var.ssh_user
        }
    }

    kubernetes_version = "v${var.k8s_version}-rancher1-1"
    ingress {
        provider = "none"
    }

    services {
        kublet {
            extra_binds = var.kubelet_extra_binds
        }
    }

    system_images {
        kubernetes = "rancher/hyperkube:v${var.k8s_version}-rancher1"
    }

    upgrade_strategy {
        drain = false
        max_unavailable_controlplane = "1"
        max_unavailable_worker       = "10%"
    }
}

resource "local_file" "kubeconfig" {
    depends_on = [rke_cluster.main]
    filename = var.kubeconfig_path
    content  = rke_cluster.main.kube_config_yaml
}