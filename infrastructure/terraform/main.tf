#ECR Repository Block
resource "aws_ecr_repository" "cloudops" {
  name                 = "cloudops-status-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = "CloudOps"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

#GitHub OIDC Block
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

#Trust Policy for GitHub Account/Repositry
data "aws_iam_policy_document" "github_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:tjeanb@100547503/cloudops-status-api@1425932202:ref:refs/heads/main"]
    }
  }
}

#IAM Role for ECR
resource "aws_iam_role" "github_ecr" {
  name               = "cloudops-github-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}


#Permission Policy for IAM Role to push images
data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid = "GetECRAuthorizationToken"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid = "PushCloudOpsImages"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = [
      aws_ecr_repository.cloudops.arn
    ]
  }
}

resource "aws_iam_role_policy" "github_ecr_push" {
  name   = "cloudops-ecr-push-policy"
  role   = aws_iam_role.github_ecr.id
  policy = data.aws_iam_policy_document.ecr_push.json
}