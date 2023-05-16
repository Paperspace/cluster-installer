module "cluster_metal" {
  source = "../"

  name                        = "cluster-name"
  artifacts_access_key_id     = "artifacts-access-key-id"
  artifacts_path              = "s3://artifacts-bucket"
  artifacts_secret_access_key = "artifacts-secret-access-key"

  cluster_apikey              = "cluster-apikey-from-paperspace-com"
  cluster_authorization_token = "cluster-authorization-token-from-paperspace.com"
  cluster_handle              = "cluster-handle-from-paperspace-com"
  domain                      = "cluster.mycompany.com"

  k8s_workers = [
    {
      ip               = "worker_ip1"
      internal-address = "internal_ip1"
      pool-type        = "gpu"
      pool-name        = "metal-gpu"
    },
    {
      ip               = "worker_ip2"
      internal-address = "internal_ip2"
      pool-type        = "cpu"
      pool-name        = "metal-cpu"
    }
  ]

  shared_storage_path   = "/srv/cluster"
  shared_storage_server = "shared-nfs-storage.com"
  ssh_key_path          = "cluster_rsa"
  ssh_user              = "ubuntu"

  is_tls_config_from_file = false
  tls_cert                = ""
  tls_key                 = ""

  external_s3_port    = "8443"
  docker_hub_username = "docker-user"
  docker_hub_password = "docker-password"
}
