
#kreuzwerker docker provider
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}
# registry and local docker host config
provider "docker" {
  host     = var.docker_url
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]

  registry_auth {
    address     = "registry-1.docker.io"
    config_file = pathexpand("~/.docker/config.json")
  }
}

# define docker_url 
variable docker_url {
    type = string
}

# create the private prometheus network
resource "docker_network" "prometheus-network" {
  name = "prometheus-network"
  driver = "bridge"
  check_duplicate = true
}

# create the volume for prometheus to persist the db
resource "docker_volume" "prometheus-data" {
  name = "prometheus-data"
}

# Creating a Docker Image for prometheus with the latest as the Tag.
resource "docker_image" "prometheus" {
  name = "bitnami/prometheus:latest"
  force_remove = true
}

# Creating a Docker Container using the latest bitnami/prometheus image.
resource "docker_container" "prometheus" {
  image             = docker_image.prometheus.image_id
  name              = "prometheus"
  must_run          = true
  publish_all_ports = true

  volumes {
    container_path  = "/opt/bitnami/prometheus/data"
    host_path = "/home/twowheelb/workspace/tf/docker/prometheus-data"
    volume_name = "prometheus-data"
  }
  networks_advanced {
    name            = docker_network.prometheus-network.id
  }
}