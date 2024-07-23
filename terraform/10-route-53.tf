# resource "aws_route53_zone" "hosted-zone" {
#   name = "gowdasagar.online"

#   tags = {
#     Name = "test-hosted-zone"
#     provision = "terraform"
#   }
# }


# resource "aws_route53_record" "alias-record" {
#   zone_id = aws_route53_zone.hosted-zone.zone_id
#   name    = "app.gowdasagar.online"
#   type    = "A"

#   alias {
#     name                   = data.aws_lb.ingress.dns_name
#     zone_id                = data.aws_lb.ingress.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "grafana-record" {
#   zone_id = aws_route53_zone.hosted-zone.zone_id
#   name    = "grafana.gowdasagar.online"
#   type    = "A"

#   alias {
#     name                   = data.aws_lb.grafana.dns_name
#     zone_id                = data.aws_lb.grafana.zone_id
#     evaluate_target_health = true
#   }
# }
# resource "aws_route53_record" "prometheus-record" {
#   zone_id = aws_route53_zone.hosted-zone.zone_id
#   name    = "prometheus.gowdasagar.online"
#   type    = "A"

#   alias {
#     name                   = data.aws_lb.prometheus.dns_name
#     zone_id                = data.aws_lb.prometheus.zone_id
#     evaluate_target_health = true
#   }
# }

# data "aws_lb" "ingress" {
#   arn  = var.ingress_arn
#   name = var.ingress_name
# }

# data "aws_lb" "grafana" {
#   arn  = var.grafana_arn
#   name = var.grafana_name
# }

# data "aws_lb" "prometheus" {
#   arn  = var.prometheus_arn
#   name = var.prometheus_name
# }