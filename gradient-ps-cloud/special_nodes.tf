resource "paperspace_script" "gradient_machine_workspace" {
  count       = var.gradient_workspace_vm_enabled ? 1 : 0
  name        = "Gradient Workspace Controller Node Setup"
  description = "Gradient Workspace Controller Node Script"
  script_text = templatefile("${path.module}/templates/setup-script.tpl", {
    kind                         = "worker"
    gpu_enabled                  = false
    rancher_command              = rancher2_cluster.main.cluster_registration_token[0].node_command
    ssh_public_key               = tls_private_key.ssh_key.public_key_openssh
    admin_management_private_key = ""
    admin_management_public_key  = tls_private_key.admin_management_key.public_key_openssh
    registry_mirror              = local.region_to_mirror[var.region]
    pool_type                    = "workspace"
    pool_name                    = "workspace"
  })
  is_enabled = true
  run_once   = true
}

resource "paperspace_machine" "gradient_workspace_node" {
  count = var.gradient_workspace_vm_enabled ? 1 : 0
  depends_on = [
    paperspace_script.gradient_machine_workspace,
    tls_private_key.ssh_key,
  ]

  region           = var.region
  name             = "${var.name}-workspace-manager"
  machine_type     = var.machine_type_admin
  size             = var.machine_storage_admin
  billing_type     = "hourly"
  assign_public_ip = true
  template_id      = var.machine_template_id_admin
  user_id          = data.paperspace_user.admin.id
  team_id          = data.paperspace_user.admin.team_id
  script_id        = paperspace_script.gradient_machine_workspace[0].id
  network_id       = paperspace_network.network.handle
  live_forever     = true
  is_managed       = true

  provisioner "remote-exec" {
    inline = ["/bin/true"]
    connection {
      timeout     = "15m"
      type        = "ssh"
      user        = "paperspace"
      host        = self.public_ip_address
      private_key = tls_private_key.ssh_key.private_key_pem
    }
  }
}