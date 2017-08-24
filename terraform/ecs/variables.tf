variable "cluster_name" {}

variable "cluster_size" {}

variable "max_price" {
  default = "0.005"
}

variable "vpc_id" {}

variable "subnets" {
  type = "list"
}

variable "valid_until" {
  default = "2019-11-04T20:44:20Z"
}

variable "ami" {}

variable "test_cidr" {}

variable "region" {}

variable "volume_size" {
  default = "22"
}

variable "key_name" {
  default = "dev"
}

/*
CloudWatch configurations.
*/

variable "CPUUtil_metric_name" {
  default = ""
}

variable "CPUUtil_period" {
  default = 60
}

variable "CPUUtil_evaluation_periods" {
  default = 2
}

variable "CPUUtil_threshold" {
  default = 2
}

variable "CPUUtil_namespace" {
  default = "AWS/ECS"
}

variable "CPUUtil_comparison_operator" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "CPUUtil_statistic" {
  default = "Average"
}

variable "MemoryUtil_metric_name" {
  default = ""
}

variable "MemoryUtil_period" {
  default = 60
}

variable "MemoryUtil_evaluation_periods" {
  default = 2
}

variable "MemoryUtil_threshold" {
  default = 2
}

variable "MemoryUtil_namespace" {
  default = "AWS/ECS"
}

variable "MemoryUtil_comparison_operator" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "MemoryUtil_statistic" {
  default = "Average"
}

variable "notification" {
  default = ["arn:aws:sns:us-west-2:1234567890:no-alarm"]
}
