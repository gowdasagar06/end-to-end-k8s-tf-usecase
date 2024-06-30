#-------------------- VARIABLES --------------------------

// Github code start connection arn 
variable "github_codestar_connection_arn" {
  type    = string
  default = "arn:aws:codestar-connections:ap-south-1:654654515013:connection/a1a65a6c-3d69-4b52-9c3b-59072cb9d60e"
}

// GitHub Repo name 
variable "GitHub_repo_name" {
  type        = string
  description = "enter value like this <username>/<repo_name>"
  default     = "gowdasagar06/end-to-end-k8s-tf-usecase"
}

// GitHub branch 
variable "GitHub_branch_name" {
  type    = string
  default = "main"
}

#-------------------- CODEPIPELINE CONFIGURATION -------------------------

// AWS codestart connection data source 
// this has to be imported because the connection confirmation can be done through console only 

resource "aws_sns_topic" "manual-approval" {
  name = "manual-approval"
}
 
resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.manual-approval.arn
  protocol  = "email"
  endpoint  = "sagargowda6666@gmail.com"  
}

data "aws_codestarconnections_connection" "github-cs" {
  arn = var.github_codestar_connection_arn
}


// code pipeline
resource "aws_codepipeline" "k8s-deployment-codepipeline" {
  name     = "eks-terraform-codepipeline"
  role_arn = aws_iam_role.apps_codepipeline_role.arn
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts_bucket.id
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
  
  depends_on = [
    aws_sns_topic.manual-approval
  ]

}

resource "aws_iam_role" "apps_codepipeline_role" {
  name = "apps-code-pipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apps_codepipeline_role_policy" {
  name = "apps-codepipeline-role-policy"
  role = aws_iam_role.apps_codepipeline_role.id

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "*"
        },
        {
         "Effect":"Allow",
         "Action":[
            "kms:Decrypt"
         ],
         "Resource":[
            "*"
         ]
      }
    ],
    "Version": "2012-10-17"
}
EOF
}