
locals {
  project = "nginx-pods"
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "nginx-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        project = "${local.project}"
      }
    }

    template {
      metadata {
        labels = {
          project = "${local.project}"
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