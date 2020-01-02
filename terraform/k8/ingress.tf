resource "kubernetes_ingress" "ingress" {
  metadata {
    name = "ingress"
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
      "alb.ingress.kubernetes.io/listen-ports"     = "[{HTTP: 80}]"
      "alb.ingress.kubernetes.io/success-codes"    = "200"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "nginx-service"
            service_port = 80
          }

          path = "/*"
        }
      }
    }
  }
}
