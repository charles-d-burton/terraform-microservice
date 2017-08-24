data "aws_caller_identity" "current" {}

/*
 * Creat the log group, you want everything managed by terraform
 * it prevents a lot of pain later
 */
resource "aws_cloudwatch_log_group" "task_log" {
  name              = "ECS-${var.service_name}"
  retention_in_days = "400"

  tags {
    Application = "${var.service_name}"
  }
}

resource "aws_iam_policy" "ecs_service" {
  name   = "ecs-service-${var.service_name}"
  policy = "${file("${path.module}/ecsService.json")}"
}

data "template_file" "task_policy" {
  template = "${file("${path.module}/taskPolicy.json")}"
}

resource "aws_iam_policy" "task_policy" {
  name   = "ecs-task-${var.service_name}"
  policy = "${data.template_file.task_policy.rendered}"
}

resource "aws_iam_policy" "autoscaling_policy" {
  name   = "autoscaling-${var.service_name}"
  policy = "${file("${path.module}/autoscalingPolicy.json")}"
}

resource "aws_iam_role" "ecs_role" {
  name = "tf_ecs_role-${var.service_name}"

  assume_role_policy = "${file("${path.module}/ecsRole.json")}"
}

resource "aws_iam_role" "task_role" {
  name               = "tf_task_${var.service_name}"
  assume_role_policy = "${file("${path.module}/taskRole.json")}"
}

resource "aws_iam_role" "autoscaling_role" {
  name               = "tf-autoscalinng-${var.service_name}"
  assume_role_policy = "${file("${path.module}/autoscalingRole.json")}"
}

resource "aws_iam_policy_attachment" "ecs_attachment" {
  name       = "tf-ecs-attachment-${var.service_name}"
  policy_arn = "${aws_iam_policy.ecs_service.arn}"
  roles      = ["${aws_iam_role.ecs_role.name}"]
}

resource "aws_iam_policy_attachment" "task_attachment" {
  name       = "tf-ecs-attachment-${var.service_name}-task"
  policy_arn = "${aws_iam_policy.task_policy.arn}"
  roles      = ["${aws_iam_role.task_role.name}"]
}

resource "aws_iam_policy_attachment" "autoscaling_attachment" {
  name       = "tf-autoscaling-attachment-${var.service_name}"
  policy_arn = "${aws_iam_policy.autoscaling_policy.arn}"
  roles      = ["${aws_iam_role.autoscaling_role.name}"]
}

#Will only attach a policy if set to true
resource "aws_iam_policy_attachment" "extra_task_attachment" {
  count      = "${var.create_task_policy}"
  name       = "tf-ecs-attachment-${var.service_name}-extra-task"
  policy_arn = "${var.task_policy_arn}"
  roles      = ["${aws_iam_role.task_role.name}"]
}

resource "aws_security_group" "allow_http" {
  name        = "tf-sg-${var.service_name}"
  description = "Allow inbound 80 and 443"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "tf-${var.service_name}"
  }
}

resource "aws_alb_target_group" "tf_alb_http" {
  name     = "${var.service_name}"
  port     = "${var.container_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    protocol            = "${var.health_check_protocol}"
    timeout             = "${var.health_check_timeout}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    matcher             = "${var.health_check_matcher}"
  }
}

resource "aws_alb" "container_alb" {
  name            = "${var.service_name}"
  internal        = "${var.internal}"
  security_groups = ["${aws_security_group.allow_http.id}"]
  subnets         = ["${var.alb_subnets}"]

  tags {
    Name        = "tf-alb-${var.service_name}"
    Environment = "dev"
  }
}

resource "aws_alb_listener" "front_end_http" {
  load_balancer_arn = "${aws_alb.container_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tf_alb_http.arn}"
    type             = "forward"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.service_name}"
  container_definitions = "${var.container_definition}"
  task_role_arn         = "${aws_iam_role.task_role.arn}"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.service_name}"
  cluster         = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${aws_iam_role.ecs_role.arn}"

  depends_on = [
    "aws_iam_role.ecs_role",
    "aws_alb_listener.front_end_http",
  ]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.tf_alb_http.arn}"
    container_name   = "${var.service_name}"
    container_port   = "${var.container_port}"
  }
}

resource "aws_appautoscaling_target" "service_target" {
  max_capacity       = 20
  min_capacity       = "${var.desired_count}"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  role_arn           = "${aws_iam_role.autoscaling_role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = ["aws_ecs_service.ecs_service"]
}

resource "aws_appautoscaling_policy" "service_down_policy" {
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Minimum"
  name                    = "scale-down-${var.service_name}"
  resource_id             = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension      = "ecs:service:DesiredCount"
  service_namespace       = "ecs"

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
  name                    = "scale-up-${var.service_name}"
  resource_id             = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension      = "ecs:service:DesiredCount"
  service_namespace       = "ecs"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 2
  }

  depends_on = ["aws_appautoscaling_target.service_target"]
}
