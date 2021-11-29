resource "aws_vpc" "doc_vpc"{
    cidr_block = "192.168.0.0/16"

    tags = {
        env = "doc"
        Name = "doc_vpc"
    }
}

resource "aws_internet_gateway" "doc_vpc_internetGateway" {
    vpc_id = aws_vpc.doc_vpc.id
}

resource "aws_subnet" "doc_vpc_subnet_public"{
    cidr_block = "192.168.1.0/24"
    vpc_id = aws_vpc.doc_vpc.id
    map_public_ip_on_launch = true
    tags = {
        env = "doc"
    }
}

resource "aws_route_table" "doc_vpc_routeTable" {
    vpc_id = aws_vpc.doc_vpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.doc_vpc_internetGateway.id
    }
}

resource "aws_route_table_association" "doc_vpc_routeTable_association" {
    subnet_id = aws_subnet.doc_vpc_subnet_public.id
    route_table_id = aws_route_table.doc_vpc_routeTable.id
}

resource "aws_security_group" "doc_vpc_securityGroup" {
    name = "doc_vpc_securityGroup"
    vpc_id = aws_vpc.doc_vpc.id
}

resource "aws_security_group_rule" "doc_vpc_securityGroup_rule_ingress22" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.doc_vpc_securityGroup.id
}
resource "aws_security_group_rule" "doc_vpc_securityGroup_rule_ingress8080" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.doc_vpc_securityGroup.id
}
resource "aws_security_group_rule" "doc_vpc_securityGroup_rule_ingress5000" {
    type = "ingress"
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.doc_vpc_securityGroup.id
}
resource "aws_security_group_rule" "doc_vpc_securityGroup_rule_egress" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.doc_vpc_securityGroup.id
}