# resource "aws_ecr_repository" "doc_ecr_fe"{
#     name = "doc_ecr_fe"
# }

# resource "aws_ecr_repository" "doc_ecr_be"{
#     name = "doc_ecr_be"
# }

resource "aws_ecs_cluster" "doc_ecs_cluster"{
    name = "doc_ecs_cluster"
    # capacity_providers = [ aws_ecs_capacity_provider.doc_ecs_capacity_provider.name ]
}

resource "aws_ecs_task_definition" "doc_ecs_task_defintion" {
    family = "doc_ecs_task_defintion"
    cpu = 1024
    memory = 1024
    container_definitions = jsonencode([
        {
            name      = "doc_ecs_service_fe"
            image     = "047318192142.dkr.ecr.us-east-1.amazonaws.com/doc_ecr_fe:latest"
            cpu       = 10
            memory    = 256
            essential = true
            portMappings = [
                {
                containerPort = 80
                hostPort      = 8080
                }
            ]
        },
        {
            name        = "doc_ecs_service_be"
            image       = "047318192142.dkr.ecr.us-east-1.amazonaws.com/doc_ecr_be:latest"
            cpu         = 10
            memory      = 256
            essential   = true
            portMappings = [
                {
                    containerPort   = 5000
                    hostPort        = 5000
                }
            ]
        }
    ])
}

resource "aws_ecs_service" "doc_ecs_service"{
    name = "doc_ecs_service"
    task_definition = aws_ecs_task_definition.doc_ecs_task_defintion.arn
    cluster = aws_ecs_cluster.doc_ecs_cluster.id
    scheduling_strategy = "DAEMON"
    load_balancer {
        target_group_arn = aws_lb_target_group.doc_lb_target_group_fe.arn
        container_name = "doc_ecs_service_fe"
        container_port = 80
    }
    depends_on = [
      aws_lb_listener.doc_lb_listener_80
    ]
}