resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "nginx-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        project = "nginx-pods"
      }
    }

    template {
      metadata {
        labels = {
          project = "nginx-pods"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
        }
      }
    }
  }
}