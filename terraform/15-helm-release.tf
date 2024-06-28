resource "helm_release" "two-tier-app" {
  name        = "two-tier-app"
  chart       = "two-tier-app"
  repository  = "./charts"
  namespace   = "two-tier-app"
  max_history = 3
  create_namespace = true
  wait             = true
  reset_values     = true

  # set {
  #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.karpenter_controller.arn
  # }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.demo.id
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.demo.endpoint
  }

  # set {
  #   name  = "aws.defaultInstanceProfile"
  #   value = aws_iam_instance_profile.karpenter.name
  # }

  depends_on = [aws_eks_node_group.private-nodes]
}

resource "helm_release" "prometheus" {
  name             = "prom"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "monitoring"
  version          = "17.1.3"
  create_namespace = true
  wait             = true
  reset_values     = true
  max_history      = 3
  # set {
  #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.karpenter_controller.arn
  # }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.demo.id
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.demo.endpoint
  }

  # set {
  #   name  = "aws.defaultInstanceProfile"
  #   value = aws_iam_instance_profile.karpenter.name
  # }

  depends_on = [aws_eks_node_group.private-nodes]
}
