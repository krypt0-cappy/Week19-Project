# Pulls the docker image
resource "docker_image" "centos" {
  name = "centos:latest"
}
