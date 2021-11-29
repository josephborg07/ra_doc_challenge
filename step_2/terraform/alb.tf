resource "aws_lb_target_group" "doc_lb_target_group_fe"{
    name = "doc-lb-target-group-fe"
    port = 8080
    protocol = "HTTP"
    vpc_id = aws_vpc.doc_vpc.id
    target_type = "instance"
}

resource "aws_lb_target_group" "doc_lb_target_group_be"{
    name = "doc-lb-target-group-be"
    port = 5000
    protocol = "HTTP"
    vpc_id = aws_vpc.doc_vpc.id
    target_type = "instance"
    health_check {
      path = "/stats"
    }
}

resource "aws_autoscaling_attachment" "doc_lb_target_attachments_fe" {
    alb_target_group_arn = aws_lb_target_group.doc_lb_target_group_fe.arn
    autoscaling_group_name = aws_autoscaling_group.doc_ecs_autoScale_group.name
}

resource "aws_autoscaling_attachment" "doc_lb_target_attachments_be" {
    alb_target_group_arn = aws_lb_target_group.doc_lb_target_group_be.arn
    autoscaling_group_name = aws_autoscaling_group.doc_ecs_autoScale_group.name
}

resource "aws_lb" "doc_alb"{
    name = "doc-alb"
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.doc_vpc_securityGroup.id]
    subnets = [aws_subnet.doc_vpc_subnet_public.id, aws_subnet.doc_vpc_subnet2_public.id]
}

resource "aws_lb_listener" "doc_lb_listener_80" {
  load_balancer_arn = aws_lb.doc_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.doc_lb_target_group_fe.arn
  }
}

resource "aws_lb_listener_rule" "doc_lb_listener_rule_fe" {
    listener_arn = aws_lb_listener.doc_lb_listener_80.arn
    priority = 15
    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.doc_lb_target_group_fe.arn
    }
    condition {
        host_header {
            values = ["ra.doc-challenge.com"]
        }
    }
}

resource "aws_lb_listener_rule" "doc_lb_listener_rule_be" {
    listener_arn = aws_lb_listener.doc_lb_listener_80.arn
    priority = 5
    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.doc_lb_target_group_be.arn
    }
    condition {
      path_pattern {
          values = ["/stats"]
      }
    }
    condition {
        host_header {
            values = ["ra.doc-challenge.com"]
        }
    }
}

output "aws_lb_public_endpoint" {
    description = "The public endpoint of the AWS LB"
    value = aws_lb.doc_alb.dns_name
}