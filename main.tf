terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}

provider "docker" {
  host     = "ssh://twowheelb@docker.berrydale.home:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

# Creating a Docker Image ubuntu with the latest as the Tag.
resource "docker_image" "ubuntu" {
  name = "ubuntu"
}

# Creating a Docker Container using the latest ubuntu image.
resource "docker_container" "webserver" {
  image             = docker_image.ubuntu.latest
  name              = "terraform-docker-test"
  must_run          = true
  publish_all_ports = true
  command = [
    "tail",
    "-f",
    "/dev/null"
  ]
}