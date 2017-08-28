module "service" {
  source              = "./docker"
  region              = "${var.region}"
  alb_subnets         = ["${module.test_vpc.public_subnets}"]
  vpc_id              = "${module.test_vpc.vpc_id}"
  cluster_name        = "${module.ecs_cluster.cluster_name}"
  zone_id             = "${aws_route53_zone.test_zone.id}"
  docker_image        = "352484006547.dkr.ecr.us-west-2.amazonaws.com/docker-mongo:latest"
  container_port      = "3000"
  env                 = "test"
  ssl_certificate_arn = "${var.ssl_certificate_arn}"
}

variable "ssl_certificate_arn" {}

output "docker_mongo_repository" {
  value = "${module.service.ecr_repository_url}"
}
