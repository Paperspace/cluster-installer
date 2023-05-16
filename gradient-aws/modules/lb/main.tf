/*
kubernetes.io/cluster/p-test     owned     
 kubernetes.io/service-name     default/traefik     
*/
resource "aws_elb" "main" {
  name               = "gradient-elb"
  availability_zones = var.availability_zones

  access_logs {
    bucket        = "foo"
    bucket_prefix = "bar"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    "kubernetes.io/cluster/${var.name}"= "owned"
    "kubernetes.io/service-name"= "default/traefik"
  }
}