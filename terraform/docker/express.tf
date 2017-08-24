data "template_file" "container_config" {
  template = "${file("${path.module}/container_definition.json")}"

  vars {
    service_name       = "${var.service_name}"
    docker_image       = "${var.docker_image}"
    cpu_units          = "${var.cpu_units}"
    memory_reservation = "${var.memory_reservation}"
    host_port          = "${var.host_port}"
    container_port     = "${var.container_port}"
  }
}

/*
 *Create ECS Service
 *this part seems convoluted with a module calling another source at a lower level
 *I've done it this way because ideally these would all be separate components
 *and sourced from github or some other source provider.  For the purposes of this
 *exercise that doesn't make a lot of sense so it's just a nested module
*/
module "express_service" {
  source               = "./ecs-services"
  cluster_name         = "${var.cluster_name}"
  container_port       = "${var.container_port}"
  host_port            = "${var.host_port}"
  service_name         = "${var.service_name}"
  desired_count        = "${var.num_containers}"
  container_definition = "${data.template_file.container_config.rendered}"
  alb_subnets          = ["${var.alb_subnets}"]
  vpc_id               = "${var.vpc_id}"
}

resource "aws_route53_record" "internal_alb_record" {
  zone_id = "${var.zone_id}"
  name    = "express.${var.region}.${var.env}.gaia.aws"
  type    = "A"

  alias {
    name                   = "${module.express_service.dns_name}"
    zone_id                = "${module.express_service.zone_id}"
    evaluate_target_health = true
  }
}
