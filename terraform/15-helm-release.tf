resource "helm_release" "my-helm-chart" {
  name        = "my-helm-chart"
  chart       = "my-helm-chart"
  repository  = "https://github.com/gowdasagar06/end-to-end-k8s-tf-usecase/tree/main/my-helm-chart"
  # namespace   = "prod"
  max_history = 3
  # create_namespace = true
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

# resource "helm_release" "prometheus_operator_crds" {
#   name       = "prometheus-operator-crds"
#   chart      = "prometheus-operator-crd"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   namespace  = "monitoring"
#   version    = "5.0.0"
#   create_namespace = true
#   wait             = true

#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.demo.id
#   }

#   set {
#     name  = "clusterEndpoint"
#     value = aws_eks_cluster.demo.endpoint
#   }

#   # set {
#   #   name  = "aws.defaultInstanceProfile"
#   #   value = aws_iam_instance_profile.karpenter.name
#   # }

#   depends_on = [aws_eks_node_group.private-nodes]
# }

# resource "helm_release" "prometheus" {
#   name             = "prom"
#   chart            = "kube-prometheus-stack"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   namespace        = "monitoring"
#   version          = "17.1.3"
#   create_namespace = true
#   wait             = true
#   reset_values     = true
#   max_history      = 3
#   # set {
#   #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#   #   value = aws_iam_role.karpenter_controller.arn
#   # }
#   set {
#     name  = "installCRDs"
#     value = "true"
#   }

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.demo.id
#   }

#   set {
#     name  = "clusterEndpoint"
#     value = aws_eks_cluster.demo.endpoint
#   }

#   # set {
#   #   name  = "aws.defaultInstanceProfile"
#   #   value = aws_iam_instance_profile.karpenter.name
#   # }

#   depends_on = [aws_eks_node_group.private-nodes]
# }

resource "helm_release" "prometheus" {
  name             = "prom"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "monitoring"
  version    = "45.7.1"
  create_namespace = true
  wait             = true
  reset_values     = true
  max_history      = 3
   values = [
    file("values.yml")
  ]
  timeout = 2000
  # set {
  #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.karpenter_controller.arn
  # }
  set {
    name  = "installCRDs"
    value = "true"
  }

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