module "service" {
  source             = "./docker"
  region             = "${var.region}"
  alb_subnets        = ["${module.test_vpc.private_subnets}"]
  vpc_id             = "${module.test_vpc.vpc_id}"
  cluster_name       = "${module.ecs_cluster.cluster_name}"
  zone_id            = "${aws_route53_zone.test_zone.id}"
  env                = "test"
}
