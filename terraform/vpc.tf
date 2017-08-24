variable "region" {}

provider "aws" {
  region = "${var.region}"
}

/*
 * Setup the base infrastructure vpcs
 *
 * Defines the networking blocks for publick and private subnets
 * Assigns them to a NAT gateway and assigns 1 subnet per Availability Zone
*/
module "test_vpc" {
  source = "./vpc"

  name               = "test_vpc"
  cidr               = "10.50.0.0/16"
  private_subnets    = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]
  public_subnets     = ["10.50.101.0/24", "10.50.102.0/24", "10.50.103.0/24"]
  enable_nat_gateway = "true"
  azs                = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

/*
 * The next blocks create the Route53 zones to put services
 * in.
 */
resource "aws_route53_zone" "test_zone" {
  name   = "test.aws"
  vpc_id = "${module.test_vpc.vpc_id}"
}

/*
 * Output the references for the created resources, can be used in other modules
 */
output "test_private_subnets" {
  value = ["${module.test_vpc.private_subnets}"]
}

output "test_public_subnets" {
  value = ["${module.test_vpc.public_subnets}"]
}

output "test_vpc_id" {
  value = "${module.test_vpc.vpc_id}"
}

output "test_private_azs" {
  value = ["${module.test_vpc.azs}"]
}

output "test_cidr" {
  value = "${module.test_vpc.vpc_cidr}"
}

output "test_public_route_table_ids" {
  value = ["${module.test_vpc.public_route_table_ids}"]
}

output "test_private_route_table_ids" {
  value = ["${module.test_vpc.private_route_table_ids}"]
}

output "test_main_route" {
  value = "${module.test_vpc.main_route}"
}

output "test_zone" {
  value = "${aws_route53_zone.test_zone.zone_id}"
}

