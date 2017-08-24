/*
 * Setup an ECS Cluster.  This consists of a Spot Fleet primarily of
 * diversified instances clustered to act as Docker hosts.
 */
module "ecs_cluster" {
  source = "./ecs"

  cluster_name = "ecs-test"
  cluster_size = "1"
  max_price    = "0.108"

  subnets            = "${module.test_vpc.private_subnets}"
  ami                = "${lookup(var.ami, var.region)}"
  vpc_id             = "${module.test_vpc.vpc_id}"
  test_cidr          = "${module.test_vpc.vpc_cidr}"
  region             = "${var.region}"
  key_name           = "test"
  #CPU Utilization CloudWatch configurations.

  CPUUtil_metric_name         = "CPUUtilization"
  CPUUtil_period              = 60
  CPUUtil_evaluation_periods  = 2
  CPUUtil_threshold           = 80
  CPUUtil_namespace           = "AWS/ECS"
  CPUUtil_comparison_operator = "GreaterThanOrEqualToThreshold"
  CPUUtil_statistic           = "Average"

  #Memory Utilization CloudWatch configurations.

  MemoryUtil_metric_name         = "MemoryUtilization"
  MemoryUtil_period              = 60
  MemoryUtil_evaluation_periods  = 2
  MemoryUtil_threshold           = 80
  MemoryUtil_namespace           = "AWS/ECS"
  MemoryUtil_comparison_operator = "GreaterThanOrEqualToThreshold"
  MemoryUtil_statistic           = "Average"
}

variable "ami" {
  description = "AWS AMI Id, if you change, make sure it is compatible with instance type, not all AMIs allow all instance types "

  default = {
    us-west-2 = "ami-a2ca61c2"
    us-east-2 = "ami-62745007"
  }
}

/*
 * Output the ECS Cluster information to us in other modules
 */

output "cluster_name" {
  value = "${module.ecs_cluster.cluster_name}"
}

output "sg_id" {
  value = "${module.ecs_cluster.instance_sg_id}"
}

output "sg_name" {
  value = "${module.ecs_cluster.instance_sg_name}"
}

