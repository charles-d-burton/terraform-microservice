# Create the IAM Roles
resource "aws_iam_instance_profile" "ecs" {
  name  = "${var.cluster_name}-ecs-instance-${var.region}"
  role = "${aws_iam_role.spot_instance_role.name}"
}

resource "aws_iam_role" "spot_fleet_role" {
  name = "spot_fleet_role_${var.region}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "spotfleet.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "spot_instance_role" {
  name = "spot_instance_role_${var.region}"

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_iam_policy" "autoscaling_policy" {
  name   = "autoscaling-${var.cluster_name}"
  policy = "${file("${path.module}/autoscalingPolicy.json")}"
}

resource "aws_iam_role" "autoscaling_role" {
  name               = "tf-autoscaling-${var.cluster_name}"
  assume_role_policy = "${file("${path.module}/autoscalingRole.json")}"
}

resource "aws_iam_policy_attachment" "autoscaling_attachment" {
  name       = "tf-autoscaling-attachment-${var.cluster_name}"
  policy_arn = "${aws_iam_policy.autoscaling_policy.arn}"
  roles      = ["${aws_iam_role.autoscaling_role.name}"]
}

#Generate the userdata
data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    cluster_name = "${var.cluster_name}"
    region       = "${var.region}"
  }
}

#Create the IAM Policies
resource "aws_iam_policy" "spot_fleet_policy" {
  name   = "spot-fleet-policy-${var.region}"
  policy = "${file("${path.module}/spot_fleet_role.json")}"
}

resource "aws_iam_policy" "spot_instance_policy" {
  name   = "spot-instance-policy-${var.region}"
  policy = "${file("${path.module}/spot_instance_role.json")}"
}

#Attach policies to roles
resource "aws_iam_policy_attachment" "fleet_attachment" {
  name       = "fleet-attachment"
  policy_arn = "${aws_iam_policy.spot_fleet_policy.arn}"
  roles      = ["${aws_iam_role.spot_fleet_role.name}"]
}

resource "aws_iam_policy_attachment" "instance_attachment" {
  name       = "instance-attachment"
  policy_arn = "${aws_iam_policy.spot_instance_policy.arn}"
  roles      = ["${aws_iam_role.spot_instance_role.name}"]
}

#Create the security group for network ingress/egress
resource "aws_security_group" "ecs_instance_sg" {
  name        = "${var.cluster_name}-instance-sg"
  description = "Instance security group for ECS"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["${var.test_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create the ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.cluster_name}"
}

#Generate the spot fleet request, loads Userdata to each instance to join it to the cluster
resource "aws_spot_fleet_request" "fleet" {
  iam_fleet_role      = "${aws_iam_role.spot_fleet_role.arn}"
  spot_price          = "${var.max_price}"
  allocation_strategy = "diversified"
  target_capacity     = "${var.cluster_size}"
  valid_until         = "${var.valid_until}"
  terminate_instances_with_expiration = true

  ######################
  #m3.medium
  ######################
  launch_specification {
    instance_type          = "m3.medium"
    ami                    = "${var.ami}"
    spot_price             = "0.108"
    key_name               = "${var.key_name}"
    iam_instance_profile   = "${aws_iam_instance_profile.ecs.name}"
    subnet_id              = "${var.subnets[0]}"
    vpc_security_group_ids = ["${aws_security_group.ecs_instance_sg.id}"]

    ebs_block_device = {
      volume_type           = "gp2"
      volume_size           = "8"
      delete_on_termination = "true"
      snapshot_id           = "snap-adca7883"
      device_name           = "/dev/xvda"
    }

    ebs_block_device = {
      volume_type           = "gp2"
      volume_size           = "${var.volume_size}"
      delete_on_termination = "true"
      device_name           = "/dev/xvdcz"
    }

    user_data = "${data.template_file.userdata.rendered}"
  }

  launch_specification {
    instance_type          = "m3.medium"
    ami                    = "${var.ami}"
    spot_price             = "0.108"
    key_name               = "${var.key_name}"
    iam_instance_profile   = "${aws_iam_instance_profile.ecs.name}"
    subnet_id              = "${var.subnets[1]}"
    vpc_security_group_ids = ["${aws_security_group.ecs_instance_sg.id}"]

    ebs_block_device = {
      volume_type           = "gp2"
      volume_size           = "8"
      delete_on_termination = "true"
      snapshot_id           = "snap-adca7883"
      device_name           = "/dev/xvda"
    }

    ebs_block_device = {
      volume_type           = "gp2"
      volume_size           = "${var.volume_size}"
      delete_on_termination = "true"
      device_name           = "/dev/xvdcz"
    }

    user_data = "${data.template_file.userdata.rendered}"
  }

  launch_specification {
    instance_type          = "m3.medium"
    ami                    = "${var.ami}"
    spot_price             = "0.108"
    key_name               = "${var.key_name}"
    iam_instance_profile   = "${aws_iam_instance_profile.ecs.name}"
    subnet_id              = "${var.subnets[2]}"
    vpc_security_group_ids = ["${aws_security_group.ecs_instance_sg.id}"]

    ebs_block_device = {
      volume_type           = "gp2"
      volume_size           = "8"
      delete_on_termination = "true"
      snapshot_id           = "snap-adca7883"
      device_name           = "/dev/xvda"
    }

    ebs_block_device = {
      volume_type           = "gp2"
      volume_size           = "${var.volume_size}"
      delete_on_termination = "true"
      device_name           = "/dev/xvdcz"
    }

    user_data = "${data.template_file.userdata.rendered}"
  }

  depends_on = ["aws_iam_role.spot_instance_role", "aws_iam_role.spot_fleet_role"]
}

/*
 * Define the autoscaling alarms
 */

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_cpu_util_cloudwatch" {
  alarm_name          = "${aws_ecs_cluster.ecs_cluster.name} ${var.CPUUtil_metric_name}"
  comparison_operator = "${var.CPUUtil_comparison_operator}"
  evaluation_periods  = "${var.CPUUtil_evaluation_periods}"
  metric_name         = "${var.CPUUtil_metric_name}"
  namespace           = "${var.CPUUtil_namespace}"
  period              = "${var.CPUUtil_period}"
  statistic           = "${var.CPUUtil_statistic}"
  threshold           = "${var.CPUUtil_threshold}"
  alarm_actions       = "${var.notification}"

  alarm_description = "CloudWatch metric alarm: ${aws_ecs_cluster.ecs_cluster.name} ${var.CPUUtil_metric_name} ${var.CPUUtil_comparison_operator}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_mem_util_cloudwatch" {
  alarm_name          = "${aws_ecs_cluster.ecs_cluster.name} ${var.MemoryUtil_metric_name}"
  comparison_operator = "${var.MemoryUtil_comparison_operator}"
  evaluation_periods  = "${var.MemoryUtil_evaluation_periods}"
  metric_name         = "${var.MemoryUtil_metric_name}"
  namespace           = "${var.MemoryUtil_namespace}"
  period              = "${var.MemoryUtil_period}"
  statistic           = "${var.MemoryUtil_statistic}"
  threshold           = "${var.MemoryUtil_threshold}"
  alarm_actions       = "${var.notification}"

  alarm_description = "CloudWatch metric alarm: ${aws_ecs_cluster.ecs_cluster.name} ${var.MemoryUtil_metric_name} ${var.MemoryUtil_comparison_operator}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
  }
}

/*
 *Setup the system autoscaling
 */
resource "aws_appautoscaling_target" "service_target" {
  max_capacity       = 50
  min_capacity       = "${var.cluster_size}"
  resource_id        = "spot-fleet-request/${aws_spot_fleet_request.fleet.id}"
  role_arn           = "${aws_iam_role.autoscaling_role.arn}"
  scalable_dimension = "ec2:spot-fleet-request:TargetCapacity"
  service_namespace  = "ec2"
}

resource "aws_appautoscaling_policy" "service_down_policy" {
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Minimum"
  name                    = "scale-down-${var.cluster_name}"
  resource_id             = "spot-fleet-request/${aws_spot_fleet_request.fleet.id}"
  scalable_dimension      = "ec2:spot-fleet-request:TargetCapacity"
  service_namespace       = "ec2"

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -2
  }

  depends_on = ["aws_appautoscaling_target.service_target"]
}

resource "aws_appautoscaling_policy" "service_up_policy" {
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Maximum"
  name                    = "scale-up-${var.cluster_name}"
  resource_id             = "spot-fleet-request/${aws_spot_fleet_request.fleet.id}"
  scalable_dimension      = "ec2:spot-fleet-request:TargetCapacity"
  service_namespace       = "ec2"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 5
  }

  depends_on = ["aws_appautoscaling_target.service_target"]
}

resource "aws_cloudwatch_metric_alarm" "service_highcpu_scaleup" {
  alarm_name          = "${var.cluster_name}-scaleup"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  alarm_description = "CPU Autoscaling alarm to scale up"

  dimensions {
    ClusterName = "${var.cluster_name}"
  }

  alarm_actions = [
    "${aws_appautoscaling_policy.service_up_policy.arn}",
  ]

  depends_on = ["aws_appautoscaling_policy.service_up_policy"]
}

resource "aws_cloudwatch_metric_alarm" "service_highcpu_scaledown" {
  alarm_name          = "${var.cluster_name}-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  alarm_description = "CPU Autoscaling alarm to scale down"

  dimensions {
    ClusterName = "${var.cluster_name}"
  }

  alarm_actions = [
    "${aws_appautoscaling_policy.service_down_policy.arn}",
  ]

  depends_on = ["aws_appautoscaling_policy.service_down_policy"]
}
