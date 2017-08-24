output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "azs" {
  value = ["${var.azs}"]
}

output "vpc_id" {
  value = "${aws_vpc.mod.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.mod.cidr_block}"
}

output "main_route" {
  value = "${aws_vpc.mod.main_route_table_id}"
}

output "public_route_table_ids" {
  value = ["${aws_route_table.public.*.id}"]
}

output "private_route_table_ids" {
  value = ["${aws_route_table.private.*.id}"]
}

output "all_route_table_ids" {
  value = "${concat(aws_route_table.private.*.id, aws_route_table.public.*.id)}"
}

output "default_security_group_id" {
  value = "${aws_vpc.mod.default_security_group_id}"
}

output "nat_eips" {
  value = ["${aws_eip.nateip.*.id}"]
}
