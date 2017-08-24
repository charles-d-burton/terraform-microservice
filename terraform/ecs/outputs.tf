output "cluster_name" {
  value = "${aws_ecs_cluster.ecs_cluster.name}"
}

output "instance_sg_id" {
  value = "${aws_security_group.ecs_instance_sg.id}"
}

output "instance_sg_name" {
  value = "${aws_security_group.ecs_instance_sg.name}"
}
