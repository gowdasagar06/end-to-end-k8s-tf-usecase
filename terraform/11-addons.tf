resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.demo.name
  addon_name   = "vpc-cni"
  # resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.demo.name
#   addon_name   = "ebs-csi-driver"
  addon_name   = "aws-ebs-csi-driver"
  # resolve_conflicts = "PRESERVE"
  # addon_version = "v1.2.0"
  # addon_version  = "v1.26.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.test_oidc_ebs.arn
    depends_on = [
    aws_eks_node_group.private-nodes,
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.demo.name
  addon_name   = "kube-proxy"
  # resolve_conflicts = "OVERWRITE"
}

# resource "aws_eks_addon" "aws_load_balancer_controller" {
#   cluster_name = aws_eks_cluster.demo.name
#   addon_name   = "aws-load-balancer-controller"
# }

# resource "aws_eks_addon" "efs_csi_driver" {
#   cluster_name = aws_eks_cluster.demo.name
# #   addon_name   = "efs-csi-driver"
#     addon_name   = "aws-efs-csi-driver"
#     service_account_role_arn = aws_iam_role.test_oidc_efs.arn
#     depends_on = [
#     aws_eks_node_group.private-nodes,
#   ]
# }
