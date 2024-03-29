resource "tls_private_key" "admin_management_key" {
  algorithm = "RSA"
}

resource "paperspace_script" "gradient_machine_setup" {
  count       = var.gradient_admin_vm_enabled ? 1 : 0
  name        = "Gradient Admin Setup"
  description = "Gradient Admin Setup Script"
  script_text = templatefile("${path.module}/templates/setup-script.tpl", {
    kind                         = "admin_public"
    gpu_enabled                  = false
    rancher_command              = rancher2_cluster.main.cluster_registration_token[0].node_command
    ssh_public_key               = tls_private_key.ssh_key.public_key_openssh
    admin_management_private_key = tls_private_key.admin_management_key.private_key_pem
    admin_management_public_key  = tls_private_key.admin_management_key.public_key_openssh
    registry_mirror              = local.region_to_mirror[var.region]
    pool_type                    = "admin"
    pool_name                    = "admin-pool"
  })
  is_enabled = true
  run_once   = true
}

resource "paperspace_machine" "gradient_admin" {
  count = var.gradient_admin_vm_enabled ? 1 : 0
  depends_on = [
    paperspace_script.gradient_machine_setup,
    tls_private_key.ssh_key,
  ]

  region           = var.region
  name             = "${var.name}-${var.admin-machine-name-suffix}"
  machine_type     = var.machine_type_admin
  size             = var.machine_storage_admin
  billing_type     = "hourly"
  assign_public_ip = true
  template_id      = var.machine_template_id_admin
  user_id          = data.paperspace_user.admin.id
  team_id          = data.paperspace_user.admin.team_id
  script_id        = paperspace_script.gradient_machine_setup[0].id
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