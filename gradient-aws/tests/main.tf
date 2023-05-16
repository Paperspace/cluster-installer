module "cluster_aws" {
    source = "../"

    name = "cluster-name"
    aws_region = "us-east-1"

    artifacts_access_key_id = "artifacts-access-key-id"
    artifacts_path = "s3://artifacts-bucket"
    artifacts_secret_access_key = "artifacts-secret-access-key"
    
    cluster_apikey = "cluster-apikey-from-paperspace-com"
    cluster_authorization_token = "cluster-authorization-token-from-paperspace.com"
    cluster_handle = "cluster-handle-from-paperspace-com"
    domain = "cluster.mycompany.com"

    tls_cert = ""
    tls_key = ""
}
