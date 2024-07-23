data "aws_codestarconnections_connection" "github-cs" {
  arn = var.github_codestar_connection_arn
}

resource "aws_codepipeline" "k8s-deployment-codepipeline" {
  name     = var.pipeline-name
  role_arn = aws_iam_role.apps_codepipeline_role.arn
  pipeline_type = "V2"
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts_bucket.id
  }
    trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "source"
      push {
        tags {
          includes = [ "${var.tag-prefix}-*" ]
        }
        
      }
    }
  }    
  stage {
    name = "Source"
    action {
      category         = "Source"
      owner            = "AWS"
      name             = "source"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      run_order        = 1
      output_artifacts = ["Source_Output"]
      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.github-cs.arn
        FullRepositoryId = var.GitHub_repo_name
        BranchName       = var.GitHub_branch_name
        DetectChanges    = true
      }
    }
  }
  stage {
    name = "Build-Terraform-Plan"

    action {
      name             = "Build-Terraform-Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 2
      region           = "ap-south-1"
      input_artifacts  = ["Source_Output"]
      output_artifacts = ["Build_Output"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild-plan.name
      }
    }
  }
  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
      run_order = 3

      # configuration {
        # NotificationArn = "${var.approve_sns_arn}"
      #   CustomData = "${var.approve_comment}"
      #   ExternalEntityLink = "${var.approve_url}"
      # }
    }
  }
  
  stage {
    name = "Build-Terraform-Apply"

    action {
      name             = "Build-Terraform-Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 4
      region           = "ap-south-1"
      input_artifacts  = ["Build_Output"]
      output_artifacts = ["Build_Output_Final"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild-apply.name
      }
    }
  }
  
  # depends_on = [
  #   aws_sns_topic.manual-approval
  # ]

}

# resource "aws_sns_topic" "manual-approval" {
#   name = "manual-approval"
# }

# resource "aws_sns_topic_subscription" "email_notification" {
#   topic_arn = aws_sns_topic.manual-approval.arn
#   protocol  = "email"
#   endpoint  = "sagargowda6666@gmail.com"        
# }

