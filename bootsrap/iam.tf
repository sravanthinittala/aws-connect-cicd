data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "apply_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringEquals"
      values   = ["repo:sravanthinittala/aws-connect-cicd:ref:refs/heads/main"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

data "aws_iam_policy_document" "plan_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringEquals"
      values   = ["repo:sravanthinittala/aws-connect-cicd:pull_request"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "github_role_apply" {
  name               = "github_role_apply"
  assume_role_policy = data.aws_iam_policy_document.apply_assume_role_policy.json
}

resource "aws_iam_role" "github_role_plan" {
  name               = "github_role_plan"
  assume_role_policy = data.aws_iam_policy_document.plan_assume_role_policy.json
}

data "aws_iam_policy_document" "plan_role_policy" {
  statement {
    sid    = "S3ReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
  statement {
    sid    = "ConnectReadAccess"
    effect = "Allow"
    actions = [
      "connect:Describe*",
      "connect:List*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "IAMReadAccess"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies"
    ]
    resources = [
      "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com",
      "arn:aws:iam::${var.aws_account_id}:role/github_role_*"
    ]
  }
}

data "aws_iam_policy_document" "apply_role_policy" {
  statement {
    sid    = "S3WriteAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
  statement {
    sid    = "ConnectWriteAccess"
    effect = "Allow"
    actions = [
      "connect:Describe*",
      "connect:List*",
      "connect:Create*",
      "connect:Update*",
      "connect:Delete*",
      "connect:Associate*",
      "connect:Disassociate*"
    ]
    resources = [
      "arn:aws:connect:us-east-1:${var.aws_account_id}:instance/*"
    ]
  }
  statement {
    sid    = "IAMOIDCManagement"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider"
    ]
    resources = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"]
  }
  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateRole",
      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:TagRole"
    ]
    resources = ["arn:aws:iam::${var.aws_account_id}:role/github_role_*"]
  }
}

# Applies policies as inline policy. Use aws_iam_policy to create separate policy along with aws_iam_role_policy_atachment
resource "aws_iam_role_policy" "plan" {
  name   = "plan_policy"
  role   = aws_iam_role.github_role_plan.id
  policy = data.aws_iam_policy_document.plan_role_policy.json
}

resource "aws_iam_role_policy" "apply" {
  name   = "apply_policy"
  role   = aws_iam_role.github_role_apply.id
  policy = data.aws_iam_policy_document.apply_role_policy.json
}