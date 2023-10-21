resource "kubernetes_deployment" "frontend" {
  metadata {
    name   = "frontend"
    labels = {
      name = "frontend"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "webapp"

      }
    }


    template {

      metadata {
        name   = "webapp"
        labels = {
          name = "webapp"

        }
      }
      spec {
        container {
          name  = "simple-webapp"
          image = "kodekloud/webapp-color:v1"
          port {
            container_port = 8080
          }
        }

      }

    }

  }

}
resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    path = lamp_stack/custom_db
    label = {

      challenge: "second"

    }
  }

}









