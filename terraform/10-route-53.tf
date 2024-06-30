resource "aws_route53_zone" "hosted-zone" {
  name = "gowdasagar.online"

  tags = {
    Name = "test-hosted-zone"
    provision = "terraform"
  }
}

//create an alias A record 
# resource "aws_route53_record" "alias-record" {
#   zone_id = aws_route53_zone.hosted-zone.zone_id
#   name    = "gowdasagar.online"
#   type    = "A"

#   alias {
#     name                   = aws_lb.httpd-NLB.dns_name
#     zone_id                = aws_lb.httpd-NLB.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "alias-record-1" {
#   zone_id = aws_route53_zone.hosted-zone.zone_id
#   name    = "nginx.sumzz.online"
#   type    = "A"

#   alias {
#     name                   = aws_lb.httpd-NLB.dns_name
#     zone_id                = aws_lb.httpd-NLB.zone_id
#     evaluate_target_health = true
#   }
# }
