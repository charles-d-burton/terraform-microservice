output "dns_name" {
  value = "${module.express_service.dns_name}"
}

output "zone_id" {
  value = "${module.express_service.zone_id}"
}

output "task_role_arn" {
  value = "${module.express_service.task_role_arn}"
}
