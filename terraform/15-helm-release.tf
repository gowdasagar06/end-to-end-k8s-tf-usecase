resource "helm_release" "my-helm-chart" {
  name        = "my-helm-chart"
  chart       = "./my-helm-chart"
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

  depends_on = [aws_eks_node_group.private-nodes,
  helm_release.prometheus,
  helm_release.grafana,
  # helm_release.nginx_ingress
  ]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "monitoring"
  create_namespace = true
  wait             = true
  reset_values     = true
  max_history      = 3
  timeout = 2000

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

  depends_on = [aws_eks_node_group.private-nodes]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  # version    = "45.7.1"
  create_namespace = true
  wait             = true
  reset_values     = true
  max_history      = 3
  #  values = [
  #   file("values.yml")
  # ]
  timeout = 2000

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

  depends_on = [aws_eks_node_group.private-nodes]
}

# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "ingress-nginx"
#   create_namespace = true
#   wait             = true
#   reset_values     = true
#   max_history      = 3
#   timeout = 2000
  
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
#   set {
#     name  = "controller.service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "controller.publishService.enabled"
#     value = "true"
#   }
#   set {
#     name  = "controller.service.annotations.service.beta.kubernetes.io/aws-load-balancer-type"
#     value = "nlb"
#   }
#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
#     value = "external"
#   }

#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
#     value = "internet-facing"
#   }
  
#   depends_on = [aws_eks_node_group.private-nodes]
# }