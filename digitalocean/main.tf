terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

# Get ssh key
data "digitalocean_ssh_key" "terraform" {
  name = "terraform" //name of key of digitalOcean account
}

variable "do_token" {}
provider "digitalocean" {
  token = var.do_token
}

# Create a droplet
resource "digitalocean_droplet" "ubuntu" {
  image              = "docker-20-04"
  name               = "ubuntu-with-docker-${count.index}"
  region             = "fra1"
  size               = "s-1vcpu-1gb" # https://developers.digitalocean.com/documentation/v2/#list-all-sizes
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  count = "7"

  user_data = <<-EOL
    #!/bin/bash
    docker run hello-world
    EOL
}
