# This module is intentionally barebones. It is intended with future tickets to have a base set of common custom checks for all clusters.
# Particulary GPUs (SIT-167). Then the calling terraform module can passthrough additional checks for cloud specific resources (SIT-170).
resource "helm_release" "node_problem_detector" {
  name       = "node-problem-detector"
  repository = "https://charts.deliveryhero.io/"
  chart      = "node-problem-detector"
  version    = var.node_problem_detector_version
  namespace  = "kube-system"
}
