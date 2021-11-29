data "aws_iam_policy_document" "doc_iam_policy_document" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "doc_iam_role" {
    name = "doc_iam_role"
    assume_role_policy = data.aws_iam_policy_document.doc_iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "doc_iam_role_attachment" {
    role       = aws_iam_role.doc_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "doc_iam_role_profile" {
  name = "doc_iam_role_profile"
  role = aws_iam_role.doc_iam_role.name
}