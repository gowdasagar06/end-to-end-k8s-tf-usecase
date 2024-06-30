# data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:default:aws-test"]
#       # values   = ["system:serviceaccount:kube-system:aws-ebs-csi-sa"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "test_oidc" {
#   assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
#   name               = "test-oidc"
# }

# resource "aws_iam_policy" "test-policy" {
#   name = "test-policy"

#   policy = jsonencode({
#     Statement = [{
#       Action = [
#         "s3:ListAllMyBuckets",
#         "s3:GetBucketLocation"
#       ]
#       Effect   = "Allow"
#       Resource = "arn:aws:s3:::*"
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "test_attach" {
#   role       = aws_iam_role.test_oidc.name
#   policy_arn = aws_iam_policy.test-policy.arn
#   # policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# output "test_policy_arn" {
#   value = aws_iam_role.test_oidc.arn
# }


data "aws_iam_policy_document" "test_oidc_assume_role_policy_ebs" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      # values   = ["system:serviceaccount:default:aws-test"]
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "test_oidc_ebs" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy_ebs.json
  name               = "test-oidc-ebs"
}

# resource "aws_iam_policy" "test-policy" {
#   name = "test-policy"

#   policy = jsonencode({
#     Statement = [{
#       Action = [
#         "s3:ListAllMyBuckets",
#         "s3:GetBucketLocation"
#       ]
#       Effect   = "Allow"
#       Resource = "arn:aws:s3:::*"
#     }]
#     Version = "2012-10-17"
#   })
# }

resource "aws_iam_role_policy_attachment" "test_attach_ebs" {
  role       = aws_iam_role.test_oidc_ebs.name
  # policy_arn = aws_iam_policy.test-policy.arn
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

output "test_policy_ebs_arn" {
  value = aws_iam_role.test_oidc_ebs.arn
}


# data "aws_iam_policy_document" "test_oidc_assume_role_policy_efs" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       # values   = ["system:serviceaccount:default:aws-test"]
#       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "test_oidc_efs" {
#   assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy_efs.json
#   name               = "test-oidc-efs"
# }

# resource "aws_iam_policy" "test-policy" {
#   name = "test-policy"

#   policy = jsonencode({
#     Statement = [{
#       Action = [
#         "s3:ListAllMyBuckets",
#         "s3:GetBucketLocation"
#       ]
#       Effect   = "Allow"
#       Resource = "arn:aws:s3:::*"
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "test_attach_efs" {
#   role       = aws_iam_role.test_oidc_efs.name
#   # policy_arn = aws_iam_policy.test-policy.arn
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
# }


# output "test_policy_efs_arn" {
#   value = aws_iam_role.test_oidc_efs.arn
# }