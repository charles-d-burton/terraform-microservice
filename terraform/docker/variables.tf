variable "region" {}

variable "service_name" {
  default = "express"
}

variable "docker_image" {
  default = "nginx"
}

variable "cluster_name" {}

variable "vpc_id" {}

variable "alb_subnets" {
  default = []
}

variable "cpu_units" {
  default = 200
}

variable "memory_reservation" {
  default = 256
}

variable "container_port" {
  default = 8080
}

variable "host_port" {
  default = 80
}

variable "num_containers" {
  default = 3
}

variable "env" {
  description = "The environment"
}

variable "zone_id" {
  description = "The Route53 zone"
}
