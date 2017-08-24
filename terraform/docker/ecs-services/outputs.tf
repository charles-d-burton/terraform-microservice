output "dns_name" {
  value = "${aws_alb.container_alb.dns_name}"
}

output "zone_id" {
  value = "${aws_alb.container_alb.zone_id}"
}

output "task_role_arn" {
  value = "${aws_iam_role.task_role.arn}"
}
