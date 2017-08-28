output "dns_name" {
  value = "${module.docker_mongo_service.dns_name}"
}

output "zone_id" {
  value = "${module.docker_mongo_service.zone_id}"
}

output "task_role_arn" {
  value = "${module.docker_mongo_service.task_role_arn}"
}

output "ecr_repository_url" {
  value = "${aws_ecr_repository.docker_mongo.repository_url}"
}
