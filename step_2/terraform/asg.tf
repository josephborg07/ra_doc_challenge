resource "aws_launch_configuration" "doc_ecs_launch_configuration" {
    name = "doc_ecs_launch_configuration"
    image_id = "ami-0fe19057e9cb4efd8"
    user_data = "#!/bin/bash\necho ECS_CLUSTER=doc_ecs_cluster >> /etc/ecs/ecs.config"
    security_groups = [aws_security_group.doc_vpc_securityGroup.id]
    iam_instance_profile = aws_iam_instance_profile.doc_iam_role_profile.name
    key_name = "joey_key_pair"
    instance_type = "t2.small"
}

resource "aws_autoscaling_group" "doc_ecs_autoScale_group" {
    name                      = "doc_ecs_autoScale_group"
    desired_capacity          = 2
    min_size                  = 1
    max_size                  = 2
    launch_configuration = aws_launch_configuration.doc_ecs_launch_configuration.name
    vpc_zone_identifier = [aws_subnet.doc_vpc_subnet_public.id, aws_subnet.doc_vpc_subnet2_public.id]
}