variable "cluster_name" {}

variable "container_port" {}

variable "host_port" {}

variable "container_definition" {}

variable "service_name" {}

variable "desired_count" {}

variable "alb_subnets" {
  default = []
}

variable "ssl_certificate_arn" {}

variable "vpc_id" {}

variable "internal" {
  default = true
}

variable "task_policy_arn" {
  default = ""
}

variable "create_task_policy" {
  default = false
}

variable "health_check_interval" {
  default = 30
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_port" {
  default = "traffic-port"
}

variable "health_check_protocol" {
  default = "HTTP"
}

variable "health_check_timeout" {
  default = 5
}

variable "health_check_healthy_threshold" {
  default = 5
}

variable "health_check_unhealthy_threshold" {
  default = 2
}

variable "health_check_matcher" {
  default = 200
}

variable "metric_name" {
  default = "HealthyHostCount"
}

variable "period" {
  default = 60
}

variable "evaluation_periods" {
  default = 5
}

variable "threshold" {
  default = 1
}

variable "comparison_operator" {
  default = "LessThanOrEqualToThreshold"
}

variable "statistic" {
  default = "Minimum"
}

variable "notification" {
  default = ["arn:aws:sns:us-west-2:1234567890:no-alarm"]
}

variable "bucket_arn" {}

/*
CloudWatch general configurations.
*/

variable "alarm_count" {
  default = "3"
}

variable "metric_names" {
  default = ["RejectedConnectionCount", "TargetConnectionErrorCount", "UnHealthyHostCount"]
}

variable "periods" {
  default = ["60", "60", "60"]
}

variable "num_cycles" {
  default = ["2", "2", "5"]
}

variable "thresholds" {
  default = ["1", "1", "1"]
}

variable "namespace" {
  default = "AWS/ApplicationELB"
}

variable "comparison_operators" {
  default = ["GreaterThanOrEqualToThreshold", "GreaterThanOrEqualToThreshold", "GreaterThanOrEqualToThreshold"]
}

variable "statistics" {
  default = ["Sum", "Sum", "Maximum"]
}

variable "region" {
}
