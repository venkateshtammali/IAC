locals {
  service_name = "nginx-service"
}


resource "kubernetes_service" "nginx_service" {
  metadata {
    name = "${local.service_name}"
  }

  spec {
    selector = {
      project = "nginx-pods"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}
