
resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = var.artifact_bucket
}


resource "aws_codebuild_project" "codebuild-plan" {
  name = var.build-plan-name
  source {
    type      = "CODEPIPELINE"
    location  = var.git_hub_repo
    buildspec = var.buildspec_path_plan
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
  name = var.build-apply-name
  source {
    type      = "CODEPIPELINE"
    location  = var.git_hub_repo
    buildspec = var.buildspec_path_apply
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