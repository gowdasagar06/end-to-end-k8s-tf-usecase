#--------------------- VARIABLES ---------------------
variable "git_hub_repo" {
  type    = string
  default = "https://github.com/gowdasagar06/end-to-end-k8s-tf-usecase.git"
}

#---------------------- CODEBUILD CONFIGURATION -----------------------

// s3 bucket for the artifcats 
resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = "usecase-artifact-bucket123"
}

// assume role policy for the codebuild role 
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


//IAM service role for the codebuild 
resource "aws_iam_role" "codebuild_service_role" {
  name               = "codebuild_service-sagar"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "codebuild_service_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.artifacts_bucket.arn,
      "${aws_s3_bucket.artifacts_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:*",
      "cloudformation:CreateChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStacks",
      "cloudformation:ExecuteChangeSet",
      "docdb-elastic:GetCluster",
      "docdb-elastic:ListClusters",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "kms:DescribeKey",
      "kms:ListAliases",
      "kms:ListKeys",
      "lambda:ListFunctions",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "redshift:DescribeClusters",
      "redshift-serverless:ListWorkgroups",
      "redshift-serverless:GetNamespace",
      "tag:GetResources",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:InvokeFunction",
      "lambda:UpdateFunctionConfiguration",
    ]
    resources = ["arn:aws:lambda:*:*:function:SecretsManager*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "serverlessrepo:CreateCloudFormationChangeSet",
      "serverlessrepo:GetApplication",
    ]
    resources = ["arn:aws:serverlessrepo:*:*:applications/SecretsManager*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::awsserverlessrepo-changesets*",
      "arn:aws:s3:::secrets-manager-rotation-apps-*/*",
    ]
  }

  depends_on = [
    aws_s3_bucket.artifacts_bucket
  ]
}


// role policy attachement
resource "aws_iam_role_policy" "codebuild_service_role_policy_attachment" {
  role   = aws_iam_role.codebuild_service_role.name
  policy = data.aws_iam_policy_document.codebuild_service_role_policy.json
}

//create the code build project for eks-deploy-plan

resource "aws_codebuild_project" "codebuild-plan" {
  name = "eks-deploy-plan"
  source {
    type      = "CODEPIPELINE"
    location  = var.git_hub_repo
    buildspec = "buildspec-plan.yml"
  }
  artifacts {
    type = "CODEPIPELINE"
    # location = aws_s3_bucket.artifacts_bucket.bucket.id
    name      = "codebuild_plan_artifact"
    packaging = "ZIP"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }
  service_role = aws_iam_role.codebuild_service_role.arn
}

resource "aws_codebuild_project" "codebuild-apply" {
  name = "eks-deploy-apply"
  source {
    type      = "CODEPIPELINE"
    location  = var.git_hub_repo
    buildspec = "buildspec-apply.yml"
  }
  artifacts {
    type = "CODEPIPELINE"
    # location = aws_s3_bucket.artifacts_bucket.bucket.id
    name      = "codebuild_apply_artifact"
    packaging = "ZIP"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }
  service_role = aws_iam_role.codebuild_service_role.arn
}


# resource "aws_ecr_repository" "python_app_repo" {
#   name                 = "python_app_repo"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }